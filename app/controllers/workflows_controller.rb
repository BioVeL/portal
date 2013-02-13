class WorkflowsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
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
    @sources, @source_descriptions = @workflow.get_inputs
    @sinks, @sink_descriptions = @workflow.get_outputs
    @processors = @workflow.get_processors
    @ordered_processors = @workflow.get_processors_in_order
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
    puts "File name:" + @workflow.workflow_filename
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
      puts response.body
      
      directory = "/tmp"
      File.open(File.join(directory, wf_name), 'w:ASCII-8BIT') do |f|
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
      # logger.info "private data: "+token.get("/data/index").body
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
        logger.info 'DEBUG: Workflow XML Elements: ' + doc.elements.count.to_s
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
      logger.info 'DEBUG: Workflow Pages: ' + page.to_s
    end
    return workflows
  end
  def get_my_exp_workflow(workflow)
    consumer_tokens=getConsumerTokens
    if consumer_tokens.count > 0
      token = consumer_tokens.first.client
      # logger.info "private data: "+token.get("/data/index").body
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
      # logger.info "private data: "+token.get("/data/index").body
      # URI for the workflow
      workflow_uri =  "http://www.myexperiment.org/workflow.xml?id="
      workflow_uri += workflow.my_exp_id.to_s  
      workflow_uri += '&elements=content-uri'
      logger.info "DEBUG: "+ workflow_uri
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
      # logger.info "private data: "+token.get("/data/index").body
      # URI for the workflow
      workflow_uri =  "http://www.myexperiment.org/workflow.xml?id="
      workflow_uri += workflow.my_exp_id.to_s  
      workflow_uri += '&elements=privileges'
      logger.info "DEBUG: "+ workflow_uri
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
