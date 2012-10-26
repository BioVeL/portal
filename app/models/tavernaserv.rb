class Tavernaserv < ActiveRecord::Base



  # start checking the runs list to see if there are any workflows running
  def self.run_update(*args)
    if args.empty?
      @runs = Run.find(:all, :conditions => ["state = 'running'"])
      #If there are runing workflows then verify if they have finished
      for runner in @runs do
        update_this_run(runner)
      end
    elsif args.size == 1 and args.first.is_a? Run
      update_this_run(args.first)
    end
  end

  # verify if the indivirual workflow is still running and if not see if outputs
  # are ready to copy
  def self.update_this_run(runner)
    #update run details with the values from the server
    check_serv   
    svrrun = @server.run(runner.run_identification, 
                         Credential.get_taverna_credentials)
    unless svrrun.nil?      
      # if the run has finished copy the outputs 
      if svrrun.status.to_s == 'finished'
        runner.expiry = svrrun.expiry
        runner.state = svrrun.status.to_s
        runner.end = svrrun.finish_time
        # if run finishes copy run output to outputs dir within run
        if runner.results.count == 0
          #puts "no results recorded for this run"
          outputs = svrrun.output_ports
          save_results(runner.id, outputs)    
          runner.save
          running_time = runner.end - runner.start
          # update workflow statistics after the run has finished
          update_workflow_stats(runner.workflow_id, running_time)
        ## what if the run has finished but there are no results?
        end
      end
    end
  end
  def self.update_workflow_stats(wf_id = 0, running_time = 0)
    wf = Workflow.find(wf_id)
    prev_run_count = wf.run_count
    prev_avg_run = wf.average_run
    wf.average_run = ((prev_run_count * prev_avg_run) + running_time ) /
                       (prev_run_count+1)
    wf.run_count = wf.run_count + 1
    wf.save 
  end
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def self.check_serv
    puts Credential.get_taverna_uri
    if (!defined?(@server) || (@server == nil)) #then
      begin
        @server = T2Server::Server.new(Credential.get_taverna_uri)
      rescue Exception => e  
        @server = nil
        puts '/no_configuration'
      end
    else
      puts '/no_configuration'
    end
  end


  #this process is called to copy the results to the local result_store
  def self.save_results(runid, outputs)
    #resultset = {}
    if outputs.nil? or outputs.empty?
      puts "#TAVSERV SAVE_RESULTS The workflow has no output ports"    
    else 
      outputs.each do |name, port|
        puts "#TAVSERV SAVE_RESULTS #{name} (port #{port.name} depth #{port.depth})"
        if port.error?
          puts "#TAVSERV SAVE_ERROR Results are errors"
          save_to_db(name, port.type, port.depth, runid, "#{runid}/result/#{name}.error", :error)
        elsif port.value.is_a?(Array)
          puts "#TAVSERV SAVE_RESULTS partial Results are in a list"
          sub_array = port.value
          save_nested(runid,name,sub_array,port.type[0],port.depth,index="")
        else
          puts "#TAVSERV SAVE_RESULTS path: #{runid}/result/#{name}  result_value: #{port.value} type: #{port.type}"
          save_to_db(name, port.type, port.depth, runid, "#{runid}/result/#{name}", port.value)                  
        end
      end
    end
    #resultset
  end
  def self.save_nested(runid, portname, sub_array, porttype, portdepth, index="")
    (0 .. sub_array.length - 1).each do |i|
      value = sub_array[i]
      if value.is_a?(Array) then
        save_nested(runid,portname,value,porttype, portdepth, i.to_s)
      else
        puts  "#TAVSERV SAVE_NESTED path #{runid}/result/#{portname}#{index=='' ? '' :'/' + index }/#{i} type: #{porttype} VALUE: #{value}"
        save_to_db(portname, porttype, portdepth, runid, "#{runid}/result/#{portname}#{index=='' ? '' :'/' + index }/#{i}", value)
      end
    end 
  end
  def self.save_to_db(name,mimetype,depth,run,filepath,value)
    result = Result.new
    result.name = name
    result.filetype = mimetype
    result.depth = depth
    result.run_id = run
    result.filepath = filepath
    if value != :error
      result.result_file = value
    else
      puts "#TAVSERV SAVE_TO_DB need to save an error: #{value}"
      #next need to copy the file on the error path to the store path. couldn't just copy every file in the out path as it is?'
      result.result_file = "an error has ocurred"
    end
    puts "#TAVSERV SAVE_TO_DB: #{value}" 
    result.save
  end
end
