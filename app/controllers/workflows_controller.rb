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
#     Finn Baccall
#     Robert Haines
#     Alan Williams
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
class WorkflowsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :download]
  before_filter :get_workflows, :only => :index
  before_filter :get_workflow, :only => :show

  # GET /workflows
  # GET /workflows.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @workflows }
    end
  end

  # GET /workflows/1
  # GET /workflows/1.json
  def show
    @selected_tab = params[:selected_tab]

    @workflow_profile = TavernaLite::WorkflowProfile.find_by_workflow_id(@workflow)
    if @workflow_profile.nil? 
      @workflow_profile = TavernaLite::WorkflowProfile.new(:workflow_id=>67) 
    end
    @sources, @source_descriptions = @workflow.get_inputs
    @custom_inputs = @workflow_profile.get_custom_inputs
    @custom_outputs = @workflow_profile.get_custom_outputs
    @sinks, @sink_descriptions = @workflow.get_outputs
    @processors = @workflow.get_processors
    @ordered_processors = @workflow.get_processors_in_order
    @workflow_errors = @workflow_profile.get_errors
    @workflow_error_codes = @workflow_profile.get_error_codes

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @workflow }
    end
  end

  # GET /workflows/new
  # GET /workflows/new.json
  def new
    search_by =""
    if !params[:search].nil?
      search_by = params[:search].strip
    end
    @workflow = Workflow.new
    @me_workflows = []
    @consumer_tokens=getConsumerTokens
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
    if (!search_by.nil? && search_by!="")
     if @consumer_tokens.count > 0
       # search for my experiment workflows
       @workflows = getmyExperimentWorkflows(@me_workflows, URI::encode(search_by))
     end
   end
   respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @workflow }
    end
  end

  # GET /workflows/1/edit
  def edit
    @workflow = Workflow.find(params[:id])
  end

  # POST /workflows
  # POST /workflows.json
  def create
    if(!params[:workflow_name].nil?)
      create_from_my_exp(params)
    else
      create_from_upload(params)
    end
  end
  def create_from_upload(params)
    @workflow = Workflow.new(params[:workflow])
    @consumer_tokens=getConsumerTokens
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
    respond_to do |format|
      @workflow.get_details_from_model
      @workflow.user_id = current_user.id
      # the model uses t2flow to get the data from the workflow file
      if @workflow.save
        format.html { redirect_to @workflow, :notice => 'Workflow was successfully added.' }
        format.json { render :json => @workflow, :status => :created, :location => @workflow }
      else
        format.html { render :action => "new", :notice => 'Workflow cannot be added.' }
        format.json { render :json => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end
  def create_from_my_exp(params)
    @workflow = Workflow.new()
    content_uri = params[:workflow_uri]
    wf_name = params[:workflow_name]
    wf_name = wf_name.downcase.gsub(" ","_").gsub(".", "") + '.t2flow'
    link_uri = params[:workflow_link]
    @consumer_tokens=getConsumerTokens
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
    # get the workflow using token
    if @consumer_tokens.count > 0
      token = @consumer_tokens.first.client
      doc = REXML::Document.new(response.body)
      response=token.request(:get, content_uri)

      directory = "/tmp"
      File.open(File.join(directory, wf_name), 'wb') do |f|
        f.puts response.body
      end
    end
    @workflow.me_file = File.open(File.join(directory, wf_name), 'r')
    @workflow.workflow_file = wf_name
    @workflow.my_experiment_id = link_uri
    respond_to do |format|
      @workflow.get_details_from_model
      @workflow.user_id = current_user.id
      # the model uses t2flow to get the data from the workflow file
      if @workflow.save
        format.html { redirect_to @workflow, :notice => 'Workflow was successfully added.' }
        format.json { render :json => @workflow, :status => :created, :location => @workflow }
      else
        format.html { render :action => "new", :notice => 'Workflow cannot be added.' }
        format.json { render :json => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end
  # PUT /workflows/1
  # PUT /workflows/1.json
  def update
    @workflow = Workflow.find(params[:id])

    respond_to do |format|
      if @workflow.update_attributes(params[:workflow])
        format.html { redirect_to @workflow, :notice => 'Workflow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflows/1
  # DELETE /workflows/1.json
  def destroy
    @workflow = Workflow.find(params[:id])
    @workflow.delete_files
    @workflow.destroy

    respond_to do |format|
      format.html { redirect_to workflows_url }
      format.json { head :no_content }
    end
  end

  def download
    @workflow = Workflow.find(params[:id])
    path = @workflow.workflow_filename
    filetype = 'application/xml'
    send_file path, :type=>filetype , :name => @workflow.name
  end

  def make_public
    @workflow = Workflow.find(params[:id])
    @workflow.shared = true
    @workflow.save!
    redirect_to :back
  end

  def make_private
    @workflow = Workflow.find(params[:id])
    @workflow.shared = false
    @workflow.save!
    redirect_to :back
  end

  def save_custom_inputs
    action = params[:commit]
    @workflow = Workflow.find(params[:id])
    @inputs, @input_desc = @workflow.get_inputs
    if action == 'Save'
      save_inputs
    elsif action == 'Reset'
      reset_inputs
    end
    respond_to do |format|
      format.html { redirect_to @workflow, :notice => 'Workflow inputs updated'}
      format.json { head :no_content }
     end
  end

  def save_inputs
    @input_desc.each do |indiv_in|
      i_name = indiv_in[0]
      file_for_i = "file_for_"+i_name
      customise_i = "customise_"+i_name
      display_i = "display_for_"+i_name
      if ((params[:file_uploads].include? i_name) &&
          params[:file_uploads][customise_i] == "1") &&
          ((params[:file_uploads].include? file_for_i) ||
           (params[:file_uploads][i_name] != ""))
        # verify if customised input exists
        wfps = WorkflowPort.where("port_type = ? and name = ?", "1", i_name)
        if wfps.empty?
          @wfp = WorkflowPort.new()
        else
          @wfp = wfps[0]
        end
        #get values for customised input
        @wfp.workflow_id = @workflow.id
        @wfp.port_type = 1 # 1 = input
        @wfp.name = i_name
        @wfp.display_control_id = params[:file_uploads][display_i]
        if params[:file_uploads].include? file_for_i
          #save file
          @wfp.file_content = params[:file_uploads][file_for_i].tempfile
          @wfp.sample_file =  params[:file_uploads][file_for_i].original_filename
          @wfp.sample_file_type = params[:file_uploads][file_for_i].content_type
        end
        if params[:file_uploads][i_name] != ""
          #save value
          @wfp.sample_value = params[:file_uploads][i_name]
        end
        #save the customisation
        @wfp.save
      elsif params[:file_uploads][customise_i] == "0"
        # reset port customisation
        wfps = WorkflowPort.where("port_type = ? and name = ?", "1", i_name)
        unless wfps.empty?
          @wfp = wfps[0]
          @wfp.delete_files
          @wfp.destroy
        end
      end
    end
  end

  def reset_inputs
    @input_desc.each do |indiv_in|
      i_name = indiv_in[0]
      wfps = WorkflowPort.where("port_type = ? and name = ?", "1", i_name)
      unless wfps.empty?
        @wfp = wfps[0]
        @wfp.delete_files
        @wfp.destroy
      end
    end
  end

  def save_custom_outputs
    action = params[:commit]
    @workflow = Workflow.find(params[:id])
    @outputs, @output_desc = @workflow.get_outputs
    selected_tab = params[:selected_tab]
    selected_choice = params[:selected_choice]

    if action == 'Save'
      save_outputs
    elsif action == 'Reset'
      reset_outputs
    end
    respond_to do |format|
      format.html { redirect_to @workflow, :notice => 'Workflow outputs updated'}
      format.json { head :no_content }
    end
  end

  def save_outputs
    @output_desc.each do |indiv_in|
      i_name = indiv_in[0]
      file_for_i = "file_for_"+i_name
      customise_i = "customise_"+i_name
      display_i = "display_for_"+i_name
      if ((params[:file_uploads].include? i_name) &&
          params[:file_uploads][customise_i] == "1") &&
          ((params[:file_uploads].include? file_for_i) ||
           (params[:file_uploads][i_name] != ""))
        # verify if customised output exists
        wfps = WorkflowPort.where("port_type = ? and name = ?", "2", i_name)
        if wfps.empty?
          @wfp = WorkflowPort.new()
        else
          @wfp = wfps[0]
        end
        #get values for customised output
        @wfp.workflow_id = @workflow.id
        @wfp.port_type = 2 # 2 = output
        @wfp.name = i_name
        @wfp.display_control_id = params[:file_uploads][display_i]
        if params[:file_uploads].include? file_for_i
          # save file
          @wfp.file_content = params[:file_uploads][file_for_i].tempfile
          @wfp.sample_file =  params[:file_uploads][file_for_i].original_filename
          @wfp.sample_file_type = params[:file_uploads][file_for_i].content_type
        end
        if params[:file_uploads][i_name] != ""
          #save value
          @wfp.sample_value = params[:file_uploads][i_name]
        end
        #save the customisation
        @wfp.save
      elsif params[:file_uploads][customise_i] == "0"
        # reset port customisation
        wfps = WorkflowPort.where("port_type = ? and name = ?", "2", i_name)
        unless wfps.empty?
          @wfp = wfps[0]
          @wfp.delete_files
          @wfp.destroy
        end
      end
    end
  end

  def reset_outputs
    @output_desc.each do |indiv_out|
      o_name = indiv_out[0]
      wfps = WorkflowPort.where("port_type = ? and name = ?", "2", o_name)
      unless wfps.empty?
        @wfp = wfps[0]
        @wfp.delete_files
        @wfp.destroy
      end
    end
  end

  def save_custom_errors
    action = params[:commit]
    @workflow = Workflow.find(params[:id])
    selected_tab = params[:selected_tab]
    selected_choice = params[:selected_choice]

    if action == 'Save'
      save_errors
    elsif action == 'Reset'
      reset_errors
    end
    respond_to do |format|
      format.html { redirect_to @workflow,
                      :notice => 'Workflow errors updated '}
      format.json { head :no_content }
    end
  end

  def save_errors
    error_codes=params[:file_uploads]
    codes_only = []
    # get just the codes
    error_codes.each do |ecode,value|
      if ecode.exclude?('id_for_') && ecode.exclude?('code_for_') && ecode.exclude?('name_for_') && ecode.exclude?('message_for_') && ecode.exclude?('pattern_for_')
        codes_only << ecode
      end
    end
    # check each code to see if it is new and if it is to be saved

    codes_only.each do |ecode|
      id_for_e      = 'id_for_'+ecode
      code_for_e    = 'code_for_'+ecode
      name_for_e    = 'name_for_'+ ecode
      message_for_e = 'message_for_'+ ecode
      pattern_for_e = 'pattern_for_' + ecode
      # customise this error?
      if (error_codes[ecode] == "1") then
        # verify if customised error exists
        wfec = WorkflowError.where("error_code = ?", ecode)
        if wfec.empty?
          wfe = WorkflowError.new()
        else
          wfe = wfec[0]
        end
        # get values for customised output
        wfe.workflow_id      = @workflow.id
        wfe.error_code       = error_codes[code_for_e]
        wfe.my_experiment_id = @workflow.my_experiment_id
        wfe.error_name       = error_codes[name_for_e]
        wfe.error_pattern    = error_codes[pattern_for_e]
        wfe.error_message    = error_codes[message_for_e]
        #save the customisation
        wfe.save
      elsif error_codes[ecode] == "0"
        # reset error customisation
        wfec = WorkflowError.where("error_code = ?", ecode)
        unless wfec.empty?
          wfe = wfec[0]
          wfe.destroy
        end
      end
    end
  end

  def reset_errors
    error_codes=params[:file_uploads]
    codes_only = []
    # get just the codes
    error_codes.each do |ecode,value|
      if ecode.exclude?('id_for_') && ecode.exclude?('code_for_') && ecode.exclude?('name_for_') && ecode.exclude?('message_for_') && ecode.exclude?('pattern_for_')
        codes_only << ecode
      end
    end
    codes_only.each do |indiv_err|
      wfer = WorkflowError.where("error_code = ?", indiv_err)
      unless wfer.empty?
        wfe = wfer[0]
        wfe.destroy
      end
    end
  end



  private

  def get_workflows
    @shared_workflows = Workflow.find_all_by_shared(true)

    if !current_user.nil?
      @workflows = Workflow.all
      if !current_user.admin
        @workflows.delete_if {|wkf| wkf.user_id != current_user.id}
      end
    end
  end

  def get_workflow
    @workflow = Workflow.find(params[:id])

    if current_user.nil?
      return login_required if !@workflow.shared?
    else
      return login_required if @workflow.user_id != current_user.id
    end
  end
  def getConsumerTokens
    MyExperimentToken.all :conditions=>
      {:user_id=>current_user.id}
  end

  def getmyExperimentWorkflows(workflows=[], search_by="")
    consumer_tokens = getConsumerTokens
    if consumer_tokens.count > 0
      token = consumer_tokens.first.client
      # URI for the packs, will return all the packs for selected page
      # PROBLEM: how do we know how many pages are there?
      workflow_uri = "http://www.myexperiment.org/search.xml?query='" + search_by
      workflow_uri += "'&type=workflow&num=100&page="
      # Get the workflows using the request token
      no_workflows = false
      page = 1
      begin
        response=token.request(:get, workflow_uri+ page.to_s)
        doc = REXML::Document.new(response.body)
        if doc.elements['search/workflow'].nil? ||
           doc.elements['search/workflow'].has_elements?
          no_workflows = true
        else
          doc.elements.each('search/workflow') do |p|
            p.attributes.each do |attrbt|
              if(attrbt[0]=='resource')
                nw_workflow=MeWorkflow.new
                nw_workflow.my_exp_id = attrbt[1].to_s.split('/').last
                if get_workflow_permissions(nw_workflow).include?("download")
                  nw_workflow.name = p.text
                  nw_workflow.id = nw_workflow.my_exp_id
                  nw_workflow.uri = attrbt[1]
                  nw_workflow = get_my_exp_workflow(nw_workflow)
                  if nw_workflow.type == "Taverna 2"
                    workflows << nw_workflow
                  end
                end
              end
            end
          end
          page +=1
        end
      end while no_workflows == false
    end
    return workflows
  end
  def get_my_exp_workflow(workflow)
    consumer_tokens=getConsumerTokens
    if consumer_tokens.count > 0
      token = consumer_tokens.first.client
      # URI for the packs, will return all the packs for selected page
      # PROBLEM: how do we know how many pages are there?
      workflow_uri = "http://www.myexperiment.org/workflow.xml?id=" +
                  workflow.id.to_s
      # Get the workflow using the request token
      response=token.request(:get, workflow_uri)
      doc = REXML::Document.new(response.body)
      workflow.name = doc.elements['workflow/title'].text
      workflow.content_uri = get_workflow_content_uri(workflow)
      workflow.description = doc.elements['workflow/description'].text
      workflow.type = doc.elements['workflow/type'].text
      # get permisions
      permissions = get_workflow_permissions(workflow)
      workflow.can_download = permissions.include?("download")
    end
    return workflow
  end

  def get_workflow_content_uri(workflow)
    consumer_tokens = getConsumerTokens
    content_uri =""
    if consumer_tokens.count > 0
      token = consumer_tokens.first.client
      # URI for the workflow
      workflow_uri =  "http://www.myexperiment.org/workflow.xml?id="
      workflow_uri += workflow.my_exp_id.to_s
      workflow_uri += '&elements=content-uri'
      response=token.request(:get, workflow_uri)
      doc = REXML::Document.new(response.body)
      doc.elements.each('workflow/content-uri') do |u|
        content_uri = u.text
      end
    end
    return content_uri
  end
  def get_workflow_permissions(workflow)
    consumer_tokens = getConsumerTokens
    elements = []
    if consumer_tokens.count > 0
      token = consumer_tokens.first.client
      # URI for the workflow
      workflow_uri =  "http://www.myexperiment.org/workflow.xml?id="
      workflow_uri += workflow.my_exp_id.to_s
      workflow_uri += '&elements=privileges'
      response=token.request(:get, workflow_uri)
      doc = REXML::Document.new(response.body)
      doc.elements.each('workflow/privileges/privilege') do |u|
        u.attributes.each do |attrbt|
          if(attrbt[0]=='type')
            elements << attrbt[1]
          end
        end
      end
    end
    return elements
  end
end
