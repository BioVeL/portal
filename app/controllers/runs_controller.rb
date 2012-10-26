gem 'ratom'
require 'atom'
class RunsController < ApplicationController
  before_filter :login_required
  # GET /runs
  # GET /runs.json
  def index  
    @runs = Run.find(:all, :order =>'start desc') 
    if (!current_user.admin?)
      @runs = Run.find_all_by_user_id(current_user.id, :order =>'start desc')
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

  def refresh
    @run = Run.find(params[:id])
    @interaction_id, @interaction_uri = get_interaction(@run.run_identification, @run.start)
    respond_to do |format|
      format.js 
    end
  end

  $feed_ns = "http://ns.taverna.org.uk/2012/interaction"
  $feed_uri = "http://localhost:8080/ah/interaction/notifications"
  def get_interaction(run_id = "7952aed1-b5e7-46ab-88ac-db08975d16c0", run_date =  DateTime.now())
    puts "*****************************************************"
    puts "MONITORING RUN TO GET INTERACTIONS*******************"
    puts "*****************************************************"

    feed = Atom::Feed.load_feed(URI.parse($feed_uri))
    replies_for_run = Array.new
    interaction = nil
    puts run_id
    puts feed.entries.count
    # Go through all the entries in reverse order and return the first which
    # does not have a reply.
    feed.each_entry do |entry|
      entry_run_id = entry[$feed_ns, "run-id"]
      puts entry[$feed_ns, "run-id"]
      if (entry_run_id.empty?)
        puts("empty")
        next
      end
      unless (entry_run_id[0] == run_id)
        puts "not equal #{entry_run_id} to #{run_id}"
        next
      end

      puts "Found equal #{entry_run_id} to #{run_id}"
      r_id = entry[$feed_ns, "in-reply-to"]
      puts "Run Date: " + run_date.to_s
      feed_datetime = entry.updated
      puts feed_datetime
      
      puts "reply ID: " + r_id.to_s
      puts "Stored Replies: " + replies_for_run.to_s
      if r_id.empty?
        if replies_for_run.include?(entry[$feed_ns, "id"][0].to_s)
          puts "This interaction has been responded already"
          next
        else
          interaction = entry
          puts "Found interaction " + interaction[$feed_ns, "id"][0]
          break
        end      
      else 
        puts "respose to interaction: " + r_id.to_s + " for run: "+ run_id
        if !replies_for_run.include?(r_id.to_s)
          replies_for_run.push r_id.to_s
        end
      end 
      if feed_datetime < run_date
        break
      end 
    end
    # Return nil if there are no interactions
    return [nil, nil] if interaction.nil?

    # Get the interaction link from the feed entry
    interaction.links.each do |link|
      if link.rel == "presentation"
        return [interaction[$feed_ns, "id"][0], link.to_s]
      end
    end

    # Should not get here but return nil just in case...
    [nil, nil]
  end  

  def interaction
    interactionid = params[:interactionid].to_s
    @run = Run.find(params[:id])
    @responded = probe_interaction(@run.run_identification, interactionid)
  end

  def probe_interaction(run_id = "7952aed1-b5e7-46ab-88ac-db08975d16c0", interaction_id = "")
    puts "*****************************************************"
    puts "MONITORING INTERACTION TO GET RESPONSE***************"
    puts "interaction " + interaction_id
    puts "*****************************************************"
    feed = Atom::Feed.load_feed(URI.parse($feed_uri))
    interaction = nil
    puts run_id
    puts feed.entries.count
    # Go through all the entries in reverse order and return true if
    # it has been replied.
    feed.each_entry do |entry|
      entry_run_id = entry[$feed_ns, "run-id"]
      puts entry[$feed_ns, "run-id"]
      if (entry_run_id.empty?)
        puts("empty")
        next
      end
      unless (entry_run_id[0] == run_id)
        puts "not equal #{entry_run_id} to #{run_id}"
        next
      end

      puts "Found equal #{entry_run_id} to #{run_id}"
      r_id = entry[$feed_ns, "in-reply-to"]
      puts "interaction id: " + interaction_id
      puts "response to: " + r_id.to_s
      if r_id.empty? && interaction_id == entry[$feed_ns, "id"][0] 
        #the interaction has not been responded
        puts "Found interaction not completed yet"
        return false;
      end
      if r_id.to_s == interaction_id.to_s
        puts "respose sent for " + run_id
        return true;
      end
      break
    end
    # Return nil if there are no interactions
    return false
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
        input_file =  "file_for_#{port.name}"
        if params[:file_uploads].include? input
          puts "1   Actual Input for #{input} as string #{params[input].to_s}"
          stringinput = params[:file_uploads][input].to_s
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
        else
          puts "Input '#{input}' has not been set."
          run.delete
          exit 1
        end
        puts "Files? #{input_file}"
        if params[:file_uploads].include? input_file
          port.file = params[:file_uploads][input_file].tempfile.path
          puts "Input '#{input}' set to use file '#{params[:file_uploads][input_file].original_filename}'"
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
      @sources, @descriptions = @workflow.get_inputs
    else
      save_run(run)
    end   
  end
  

  # Save the new run in the database
  def save_run(run)
    @run = Run.new
    puts "CREATE gets called after the new form is presented"
    puts "CREATE #{params}" 
    puts "CREATE run identifier #{cookies[:run_identification]}"
    @run.workflow_id = @workflow.id
    @run.description = @workflow.title
    @run.run_identification = run.identifier
    @run.creation = run.create_time
    @run.start = run.start_time
    @run.expiry = run.expiry
    @run.state = run.status
    @run.user_id = current_user.id

    # the run has been started so redirect to it
    respond_to do |format|
      if @run.save
        format.html { redirect_to  @run, :notice => 'The run was successfully created.' }
        format.json { render :json => @run, :status => :created, :location => @run }    
      end
    end
  end

  #this process is called to copy the results to the local result_store
  def save_results(runid, outputs)
    #resultset = {}
    "#SAVE_RESULTS"
    if outputs.empty?
      puts "#SAVE_RESULTS: The workflow has no output ports"    
    else 
      outputs.each do |name, port|
        puts "#SAVE_RESULTS: #{name} (depth #{port.depth})"
        if port.value.is_a?(Array)
          puts "#SAVE_RESULTS:  partial Results are in a list"
          sub_array = port.value
          save_nested(runid,name,sub_array,port.type[0],port.depth,index="")
        else
          puts "#SAVE_RESULTS: path: #{runid}/result/#{name}  result_value: #{port.value} type: #{port.type}"
          save_to_db(name, port.type, port.depth, runid, "#{runid}/result/#{name}", port.value)                  
        end
      end
    end
    #resultset
  end
  def save_nested(runid, portname, sub_array, porttype, portdepth, index="")
    puts  "#SAVE_NESTED: "
    (0 .. sub_array.length - 1).each do |i|
      value = sub_array[i]
      if value.is_a?(Array) then
        save_nested(runid,portname,value,porttype, portdepth, i.to_s)
      else 
        puts  "#SAVE_NESTED: path #{runid}/result/#{portname}#{index=='' ? '' :'/' + index }/#{i} type: #{porttype}"
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
    puts "#SAVE_TO_DB: #{value}" 
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
