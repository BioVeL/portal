class WorkflowPortsController < ApplicationController
  # GET /workflow_ports
  # GET /workflow_ports.json
  def index
    @workflow_ports = WorkflowPort.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @workflow_ports }
    end
  end

  # GET /workflow_ports/1
  # GET /workflow_ports/1.json
  def show
    @workflow_port = WorkflowPort.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @workflow_port }
    end
  end

  # GET /workflow_ports/new
  # GET /workflow_ports/new.json
  def new
    @workflow_port = WorkflowPort.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @workflow_port }
    end
  end

  # GET /workflow_ports/1/edit
  def edit
    @workflow_port = WorkflowPort.find(params[:id])
  end

  # POST /workflow_ports
  # POST /workflow_ports.json
  def create
    @workflow_port = WorkflowPort.new(params[:workflow_port])

    respond_to do |format|
      if @workflow_port.save
        format.html { redirect_to @workflow_port, notice: 'Workflow port was successfully created.' }
        format.json { render json: @workflow_port, status: :created, location: @workflow_port }
      else
        format.html { render action: "new" }
        format.json { render json: @workflow_port.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_ports/1
  # PUT /workflow_ports/1.json
  def update
    @workflow_port = WorkflowPort.find(params[:id])

    respond_to do |format|
      if @workflow_port.update_attributes(params[:workflow_port])
        format.html { redirect_to @workflow_port, notice: 'Workflow port was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @workflow_port.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_ports/1
  # DELETE /workflow_ports/1.json
  def destroy
    @workflow_port = WorkflowPort.find(params[:id])
    @workflow_port.destroy

    respond_to do |format|
      format.html { redirect_to workflow_ports_url }
      format.json { head :no_content }
    end
  end
  # download a sample file value 
  def download
    @workflow_port = WorkflowPort.find(params[:id])
    path = @workflow_port.sample_file_path
    filetype = MIME::Types.type_for(path)
    send_file path, :type=> filetype, :name => @workflow_port.sample_file
  end
end
