class Tavernaserv < ActiveRecord::Base
  # attr_accessible :title, :body
  @server = nil;
  @server_uri = "http://localhost:8080/ts24"
  @server_user = "taverna"
  @server_pass = "taverna"

  @credentials = T2Server::HttpBasic.new("taverna", "taverna")


  @updater_running = false
  
  def self.run_update
    @updater_running = true
    @runs = Run.find(:all).select {|r| r.results.count == 0 && (r.state.scan('running') || r.state.scan('finished') )}
    count = @runs.count
    #debugger
    check_serv
    
    puts "Current runing: #{count}\n"
    if count > 0
      for runner in @runs do
        #update each run's details with the values from the server
        svrrun = @server.run(runner.run_identification, @credentials)
        tmprn = runner
        if svrrun.nil? 
          runner.state = 'expired'
        elsif (runner.state != svrrun.status )
          runner.creation = svrrun.create_time
          runner.start = svrrun.start_time
          runner.expiry = svrrun.expiry
          runner.state = svrrun.status.to_s
          runner.end = svrrun.finish_time
          # if the new values make the run different then save the new values 
          if runner != tmprn  
             runner.save      
          end 
          # if the run has finished copy the outputs 
          if runner.state.to_s.scan('finished')
            # if run finishes copy run output to outputs dir within run
            #puts "run has finished"
            # if run does not have outputs yet
            if runner.results.count == 0
              #puts "no results recorded for this run"
              outputs = svrrun.output_ports
              save_results(runner.id, outputs)
            ##if the run has finished but there are no results
            end
          else 
            puts "run is executing"
          end
        end
        
        runner.save
      end
      puts "Current runing: #{count}\n"
    end
    puts "no more running"
    @updater_running = false
  end  

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def self.check_serv
    puts @server_uri
    if (!defined?(@server) || (@server == nil)) #then
      begin
        @server = T2Server::Server.new(@server_uri)
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
      #puts "The workflow has no output ports"    
    else 
      outputs.each do |name, port|
        #puts "#{name} (depth #{port.depth})"
        if port.value.is_a?(Array)
          #puts " partial Results are in a list"
          sub_array = port.value
          save_nested(runid,name,sub_array,port.type[0],port.depth,index="")
        else
          #puts "path: #{runid}/result/#{name}  result_value: #{port.value} type: #{port.type}"
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
        puts  "path #{runid}/result/#{portname}#{index=='' ? '' :'/' + index }/#{i} type: #{porttype}"
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
    result.result_file = value
    result.save
  end
end
