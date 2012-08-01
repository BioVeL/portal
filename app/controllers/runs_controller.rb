class RunsController < ApplicationController
  before_filter :login_required
  # GET /runs
  # GET /runs.json
  def index  
    Tavernaserv.run_update()   
    @runs = Run.all 
    if (!current_user.admin?)
      @runs = Run.find_all_by_user_id(current_user.id)
    end 
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @runs }
    end
  end

  # GET /runs/1
  # GET /runs/1.json
  def show
    @run = Run.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @run }
    end
  end

  # GET /runs/new
  # GET /runs/new.json
  def new
    @run = Run.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @run }
    end
  end

  # GET /runs/1/edit
  def edit
    @run = Run.find(params[:id])
  end

  # POST /runs
  # POST /runs.json
  def create
    @run = Run.new(params[:run])

    respond_to do |format|
      if @run.save
        format.html { redirect_to @run, :notice => 'Run was successfully created.' }
        format.json { render :json => @run, :status => :created, :location => @run }
      else
        format.html { render :action => "new" }
        format.json { render :json => @run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /runs/1
  # PUT /runs/1.json
  def update
    @run = Run.find(params[:id])

    respond_to do |format|
      if @run.update_attributes(params[:run])
        format.html { redirect_to @run, :notice => 'Run was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @run.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /runs/1
  # DELETE /runs/1.json
  def destroy
    @run = Run.find(params[:id])
    @run.delete_results
    @run.destroy

    respond_to do |format|
      format.html { redirect_to runs_url }
      format.json { head :no_content }
    end
  end
    #GET /workflows/1/newrun
  def new_run
    cookies[:run_identification]=""
    puts "number of parameters: #{params.count}"
    unless params[:id].nil?
      get_workflow()
      puts "Generating new run for: #{@workflow.name}"
    end
      @sources = {}
      @descriptions = {}
      @files = {}
    unless params[:workflow_id].nil?
      puts 'using submitted inputs'
      check_server()    
      run = $server.create_run(@workflow.get_file, Credential.get_taverna_credentials)
      cookies[:run_identification] = run.identifier
      run.input_ports.each_value do |port|
        input = port.name  
        if params.include? input
          puts "1   Actual Input for #{input} as string #{params[input].to_s}"
          stringinput = params[input].to_s
          puts "2   #{stringinput.class}"
        if stringinput.include?("[") and stringinput.include?("]")
            puts "3   Input is a list"
            inputarray = stringinput[1..-2].split(',').collect! {|n| n.to_s}
            puts '4   Values' 
            puts inputarray
            puts inputarray.class
            port.value = inputarray
          else
            port.value = stringinput
          end
          puts "Input '#{input}' set to #{port.value}"   
          puts "actual value = #{run.input_ports[input].value}       "
          #if run.input_port("name").nil?
          #  puts 'no values assigned'
          #  run.input_port("name").value = "Surprise!!"
          #end
        elsif files.include? input
          port.file = files[input]
          puts "Input '#{input}' set to use file '#{port.file}'"
        else
          puts "Input '#{input}' has not been set."
          run.delete
          exit 1
        end
      end
      # determine if an rserver is being called
      if @workflow.connects_to_r_server?
        rs_cred = Credential.find_by_server_type_and_default_and_in_use("rserver",true,true)
        run.add_password_credential(rs_cred.url,rs_cred.login,rs_cred.password)
      end
      run.start()
    end
    

    if !(@workflow.has_parameters?) then 
      # for workflows with no input
      puts 'no inputs'
      # create a new run
      check_server()    
      run = $server.create_run(@workflow.get_file, Credential.get_taverna_credentials)
      cookies[:run_identification] = run.identifier
      if @workflow.connects_to_r_server?
        rs_cred = Credential.find_by_server_type_and_default_and_in_use("rserver",true,true)
        run.add_password_credential(rs_cred.url,rs_cred.login,rs_cred.password)
      end
      run.start()
      save_run(run)
    elsif cookies[:run_identification]=="" 
      # if workflow has inputs
      puts 'workflow has inputs'
      get_inputs()
    else
      save_run(run)
    end   
  end
  

  # get the inputs from the model
  def get_inputs
    # get the workflow t2flow model
    puts 'getting inputs from model'
    model = @workflow.get_model
    # collect the sources and their descriptions
    model.sources().each{|source|
      example_values = source.example_values
      if ((!example_values.nil?) && (example_values.size == 1)) then
        @sources[source.name] = example_values[0]
      else
        @sources[source.name] = ""
      end
      description_values = source.descriptions
      if ((!description_values.nil?) && (description_values.size == 1)) then
        @descriptions[source.name] = description_values[0]
      else
        @descriptions[source.name] = ""
      end  
    }
  end
  # Save the new run in the database
  def save_run(run)
    @run = Run.new
    puts "CREATE gets called after the new form is presented"
    puts "CREATE #{params}" 
    puts "CREATE run identifier #{cookies[:run_identification]}"
    @run.workflow_id = @workflow.id
    @run.description = @workflow.name + " " + @workflow.workflow_file
    @run.run_identification = run.identifier
    @run.creation = run.create_time
    @run.start = run.start_time
    @run.expiry = run.expiry
    @run.state = run.status
    @run.user_id = current_user.id
    @run.save
  end
  def update_all
    # ensure the server has been instantiated
    check_server()    
    @runs.each do |rn|
      #update each run's details with the values from the server
      svrrun = $server.run(rn.run_identification, Credential.get_taverna_credentials)
      tmprn = rn
      unless svrrun.nil?
      #if the state of the run has changed since the last update
        if (rn.state != svrrun.status)
          rn.state = svrrun.status
          rn.creation = svrrun.create_time
          rn.start = svrrun.start_time
          rn.expiry = svrrun.expiry
          rn.state = svrrun.status
          #rn.user_id = current_user.id
          #puts "USER: #{current_user.id} #{current_user.login}"
          rn.end = svrrun.finish_time
          # if the new values make the run different then save the new values 
          if rn != tmprn  
             rn.save      
          end 
          # if the run has finished copy the outputs 
          if rn.state.to_s.eql?('finished')
            # if run finishes copy run output to outputs dir within run
            #puts "run has finished"
            # if run does not have outputs yet
            if rn.results.count == 0
              #puts "no results recorded for this run"
              outputs = svrrun.output_ports
              save_results(rn.id, outputs)
            end
          else 
            #puts "run is executing"
          end
        end
      else
        rn.state = 'expired'
        rn.save
      end
    end
  end

  #this process is called to copy the results to the local result_store
  def save_results(runid, outputs)
    #resultset = {}
    if outputs.empty?
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
  def save_nested(runid, portname, sub_array, porttype, portdepth, index="")
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
  def save_to_db(name,mimetype,depth,run,filepath,value)
    result = Result.new
    result.name = name
    result.filetype = mimetype
    result.depth = depth
    result.run_id = run
    result.filepath = filepath
    result.result_file = value
    #result.user_id = current_user.id
    #puts "USER: #{current_user.id} #{current_user.login}"
    result.save
  end
  
  private
  # Get the workflow that will be executed
  def get_workflow
    puts "getting workflow for #{params[:id]}"
    @workflow = Workflow.find(params[:id])
  end
    # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def check_server()
    if (!defined?($server) || ($server == nil)) #then
      #settings = YAML.load(IO.read(File.join(File.dirname(__FILE__), "config.yaml")))      #if settings
      #  $server_uri = settings['server_uri']
        begin
         $server = T2Server::Server.new(Credential.get_taverna_uri)
        rescue Exception => e  
          $server = nil
          redirect_to '/no_configuration'
        end
      #else
      #  redirect_to '/no_configuration'
    end
  end
end
