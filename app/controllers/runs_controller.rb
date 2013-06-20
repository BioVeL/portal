# Copyright (c) 2012-2013 Cardiff University, UK.
# Copyright (c) 2012-2013 The University of Manchester, UK.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the names of The University of Manchester nor Cardiff University nor
#   the names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# 
# Authors
#     Abraham Nieva de la Hidalga
#     Robert Haines
# 
# Synopsis 
# 
# BioVeL Portal is a prototype interface to Taverna Server which is 
# provided to support easy inspection and execution of workflows.
# 
# For more details see http://www.biovel.eu
# 
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
gem 'ratom'
require 'atom'
class RunsController < ApplicationController
  before_filter :login_required, :except => [:new_run, :show, :refresh, 
                                             :refresh_list, :interaction, 
                                             :index, :destroy]

  # GET /runs
  # GET /runs.json
  def index  
    if current_user.nil?
      @runs = Run.find_all_by_user_id(nil, :order =>'start desc')
    else
      if !current_user.admin?
        @runs = Run.find_all_by_user_id(current_user.id, :order =>'start desc')
      else
        @runs = Run.find(:all, :order =>'start desc')
      end
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
    return login_required if current_user.nil? && !@run.user_id.nil?

    @sinks, @sink_descriptions = Workflow.find(@run.workflow_id).get_outputs
    @run_error_codes = @run.get_error_codes
    
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
    Tavernaserv.delete_run(@run.run_identification)
    @run.delete_results
    @run.destroy
    
    respond_to do |format|
      format.html { redirect_to runs_url, :notice => 'Run deleted.'  }
      format.json { head :no_content }
    end
  end

  def refresh
    @run = Run.find(params[:id])
    @interaction_id, @interaction_uri = get_interaction(@run.run_identification)
    @sinks, @sink_descriptions = Workflow.find(@run.workflow_id).get_outputs
    respond_to do |format|
      format.js 
    end
  end
  
  def refresh_list
    run_count = Integer(params[:runs])
    running_on_client = Integer(params[:running])
    runs={}
    running_now=0
    if current_user.nil?
      runs = Run.find_all_by_user_id(nil)
    else
      if !current_user.admin?
        runs = Run.find_all_by_user_id(current_user.id, :order =>'start desc')
      else
        runs = Run.find(:all, :order =>'start desc')
      end
    end
    if current_user.nil?
      running_now = Run.find_all_by_user_id_and_state(nil,'running').count
    else
      if !current_user.admin?
        running_now = Run.find_all_by_user_id_and_state(nil,'running', :order =>'start desc').count
      else
        running_now = Run.find_all_by_state('running', :order =>'start desc').count
      end
    end
    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    if runs.count != run_count || running_now != running_on_client
      @runs = runs
      puts run_count.to_s + " != " + runs.count.to_s
    else 
      @runs = {}
    end

    puts run_count 
    puts params[:running]
    puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

    respond_to do |format|
      format.js 
    end
  end


  $feed_ns = "http://ns.taverna.org.uk/2012/interaction"
  $feed_uri = "http://localhost:8080/ah/interaction/notifications?limit=1000"
  def get_interaction(run_id = "7952aed1-b5e7-46ab-88ac-db08975d16c0")
    interaction = nil
    # Find if there is an entry that does not have a reply
    # Get all interactions for the run
    entries = InteractionEntry.find_all_by_run_id_and_response(run_id,false)
    entries.each do |entry|
      responded = InteractionEntry.find_all_by_in_reply_to(entry.taverna_interaction_id).count
      if responded != 0 then 
        # Interaction has been responded already
        next
      else
        # found interaction with no response
        interaction = entry
        break
      end      
    end
    if interaction.nil? then
      # Return nil if there are no interactions for run
      return [nil, nil] 
    else
      # return the unresponded interaction 
      puts "RETURNED: " + interaction.interaction_id + " " + interaction.href
      return [interaction.interaction_id, interaction.href]
    end

    # Should not get here but return nil just in case...
    [nil, nil]
  end  

  def interaction
    @run = Run.find(params[:id])
    interactionid = params[:interactionid].to_s
    puts interactionid
    @responded = probe_interaction(interactionid)
  end

  def probe_interaction(interaction_id = "")
    return false if interaction_id.nil?
    # Look if interaction has been replied.
    puts interaction_id
    entry = InteractionEntry.find_by_interaction_id(interaction_id)
    return false if entry.nil?
    responded = InteractionEntry.find_all_by_in_reply_to(entry.taverna_interaction_id).count
    if responded != 0 then 
      # Interaction has been responded already
      return true
    else
      # found interaction with no response
      return false
    end      
  end
  

  #GET /workflows/1/newrun
  def new_run
    
    cookies[:run_identification]=""
    unassigned_inputs = false
    Rails.logger.info "#NEW RUN (#{Time.now}): number of parameters: #{params.count}" #- 1

    unless params[:id].nil?
      get_workflow()
      Rails.logger.info "#NEW RUN (#{Time.now}): Generating new run for: #{@workflow.name}" # -2
    end
    if !params[:file_uploads].nil?
      run_name = params[:file_uploads][:run_name].nil? ? @workflow.title : params[:file_uploads][:run_name]
    end
    @sources = {}
    @descriptions = {}
    @files = {}
    @custom_inputs = nil
    unless params[:workflow_id].nil?      
      if inputs_provided(params)
        Rails.logger.info "#NEW RUN (#{Time.now}): using submitted inputs"
        check_server()
        unless $server.nil?     
          run = $server.create_run(@workflow.get_file, Credential.get_taverna_credentials)
          cookies[:run_identification] = run.identifier
          run.input_ports.each_value do |port|
            input = port.name  
            input_file =  "file_for_#{port.name}"
            default_input_file =  "default_file_for_#{port.name}"
            if params[:file_uploads].include? input
              Rails.logger.info "#NEW RUN (#{Time.now}): 1 Actual Input for #{input} as string #{params[input].to_s}"
              stringinput = params[:file_uploads][input].to_s
              Rails.logger.info "#NEW RUN (#{Time.now}): 2   #{stringinput.class}"
              if stringinput.include?("[") and stringinput.include?("]")
                stringinput.sub! '[',''
                stringinput.sub! ']',''
                Rails.logger.info "#NEW RUN (#{Time.now}): 3   Input is a list"
                inputarray = stringinput.split(',').collect! {|n| n.to_s}
                Rails.logger.info "#NEW RUN (#{Time.now}): 4   Values"
                Rails.logger.info "#NEW RUN (#{Time.now}): " + inputarray.to_s
                Rails.logger.info "#NEW RUN (#{Time.now}): " + inputarray.class.to_s
                port.value = inputarray
              else
                port.value = stringinput
              end
              Rails.logger.info "#NEW RUN (#{Time.now}): Input '#{input}' set to #{port.value}"   
              Rails.logger.info "#NEW RUN (#{Time.now}): actual value = #{run.input_ports[input].value}       "
              if run.input_port(input).nil?
                Rails.logger.info "#NEW RUN (#{Time.now}): no values assigned"
              end
            else
              Rails.logger.info "#NEW RUN (#{Time.now}): Input '#{input}' has not been set."
              run.delete
              exit 1
            end
            Rails.logger.info "#NEW RUN (#{Time.now}): Files? #{input_file}"

            puts "#NEW RUN (#{Time.now}): Default Files? #{params[:file_uploads][default_input_file]}"

            if params[:file_uploads].include? input_file
              port.file = params[:file_uploads][input_file].tempfile.path
              Rails.logger.info "#NEW RUN (#{Time.now}): Input '#{input}' set to use file '#{params[:file_uploads][input_file].original_filename}'"
            elsif params[:file_uploads].include? default_input_file
              port.file = params[:file_uploads][default_input_file].to_s
              puts "#NEW RUN (#{Time.now}): Input '#{input}' set to use default file '#{params[:file_uploads][default_input_file].to_s}'"
            end
          end

          # determine if an rserver is being called
          if @workflow.connects_to_r_server?
            rs_cred = Credential.find_by_server_type_and_default_and_in_use("rserver",true,true)
            run.add_password_credential(rs_cred.url,rs_cred.login,rs_cred.password)
          end
          run.start()
        else
          puts 
            "#NEW RUN (#{Time.now}): Server Down - Redirected to back"    
          redirect_to :back,  :flash => {:error => "Server Busy, try again later"}
        end 
       else
      # missing some or all inputs
         Rails.logger.info "#NEW RUN (#{Time.now}): Cannot start run, missing inputs"
      end      
    end

   if cookies[:run_identification]=="" 
      # if workflow has inputs
      @sources, @descriptions = @workflow.get_inputs
      @custom_inputs = @workflow.get_custom_inputs
    else
      save_run(run, run_name)
    end   
  end

  def inputs_provided(params)
    @sources, @descriptions = @workflow.get_inputs
    inputs_provided = true
    @sources.each do |port|
      input = port[0]
      input_file = "file_for_#{port[0]}"
      default_input_file =  "default_file_for_#{port[0]}"
      if  !(params[:file_uploads].include? input) && !(params[:file_uploads].include? input_file)
        unless port[1].blank?
          Rails.logger.info "#NEW RUN (#{Time.now}): No input for #{input}, using example value #{port[1]}"
          params[:file_uploads][input] = port[1]
        else
          inputs_provided = false
          puts 
            "#NEW RUN (#{Time.now}):*****************************************"
          puts 
            "#NEW RUN (#{Time.now}):**          Missing Inputs             **"
          puts 
            "#NEW RUN (#{Time.now}):          " + input 
          puts 
            "#NEW RUN (#{Time.now}):*****************************************"
          break
        end
      end

      value = params[:file_uploads][input].to_s
      if (value =="") && !(params[:file_uploads].include? input_file)
        unless port[1].blank?
          Rails.logger.info "#NEW RUN (#{Time.now}): No input for #{input}, using example value #{port[1]}"
          params[:file_uploads][input] = port[1]
        else
          inputs_provided = false
          Rails.logger.info "#NEW RUN (#{Time.now}):*****************************************"
          Rails.logger.info "#NEW RUN (#{Time.now}):**          Missing Inputs             **"
          Rails.logger.info "#NEW RUN (#{Time.now}):           " + input  + ""
          Rails.logger.info "#NEW RUN (#{Time.now}):Detected:  " + value 
          Rails.logger.info "#NEW RUN (#{Time.now}):*****************************************"
          break
        end
      end
      
    end
    return inputs_provided
  end

  # Save the new run in the database
  def save_run(run, run_name)
    @run = Run.new
    puts "CREATE gets called after the new form is presented"
    puts "CREATE #{params}" 
    puts "CREATE run identifier #{cookies[:run_identification]}"
    @run.workflow_id = @workflow.id
    @run.description = run_name
    @run.run_identification = run.identifier
    @run.creation = run.create_time
    @run.start = run.start_time
    @run.expiry = run.expiry
    @run.state = run.status
    @run.user_id = current_user.nil? ? nil : current_user.id

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
      Rails.logger.info "#SAVE_RESULTS: The workflow has no output ports"    
    else 
      outputs.each do |name, port|
        Rails.logger.info "#SAVE_RESULTS: #{name} (depth #{port.depth})"
        if port.value.is_a?(Array)
          Rails.logger.info "#SAVE_RESULTS:  partial Results are in a list"
          sub_array = port.value
          save_nested(runid,name,sub_array,port.type[0],port.depth,index="")
        else
          Rails.logger.info "#SAVE_RESULTS: path: #{runid}/result/#{name}  result_value: #{port.value} type: #{port.type}"
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
    Rails.logger.info "#SAVE_TO_DB: #{value}" 
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
  $error_code = 0 # 0 no error, 1 server busy, 2 server down
  
  def check_server()
    if (!defined?($server) || ($server == nil)) #then
      begin
        $server = T2Server::Server.new(Credential.get_taverna_uri)
        req = Net::HTTP.new($server.uri.host, $server.uri.port)
        res = req.request_head($server.uri.path)
      rescue Exception => e  
        Rails.logger.info "#CHECK SERVER ERROR (#{Time.now}): Server down" 
        #email if server is not responding
        credential = Credential.find_by_server_type_and_default_and_in_use("ts",true,true)
        AdminMailer.server_unresponsive(credential).deliver
        $server = nil   
      end
    end
    max_runs = $server.run_limit(Credential.get_taverna_credentials)
    running_now = $server.runs(Credential.get_taverna_credentials).count 
    if running_now == max_runs
      $server = nil 
      Rails.logger.info "#CHECK SERVER ERROR (#{Time.now}): Server full" 
    end
  end
end
