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
    @workflow = Workflow.new
    @consumer_tokens=getConsumerTokens
    @services=OAUTH_CREDENTIALS.keys-@consumer_tokens.collect{|c| c.class.service_name}
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
    @workflow = Workflow.new(params[:workflow])
    puts "File name:" + @workflow.workflow_filename
    respond_to do |format|
      @workflow.get_details_from_model
      @workflow.user_id = current_user.id
      if @workflow.save
        # the model will use t2flow to get the data from the workflow file
        @workflow.save
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
end
