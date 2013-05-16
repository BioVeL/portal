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
#
# Synopsis 
# 
# BioVeL Taverna Lite  is a prototype interface to Taverna Server which is 
# provided to support easy inspection and execution of workflows.
# 
# For more details see http://www.biovel.eu
# 
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359. 
require 'mime/types'
class WorkflowPortsController < ApplicationController
  # GET /workflow_ports
  # GET /workflow_ports.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @workflow_ports }
    end
  end

  # GET /workflow_ports/1
  # GET /workflow_ports/1.json
  def show
    @workflow_port = WorkflowPort.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @workflow_port }
    end
  end

  # GET /workflow_ports/new
  # GET /workflow_ports/new.json
  def new
    @workflow_port = WorkflowPort.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @workflow_port }
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
        format.html { redirect_to @workflow_port, :notice => 'Workflow port was successfully created.' }
        format.json { render :json => @workflow_port, :status => :created, :location => @workflow_port }
      else
        format.html { render :action => "new" }
        format.json { render :json => @workflow_port.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_ports/1
  # PUT /workflow_ports/1.json
  def update
    @workflow_port = WorkflowPort.find(params[:id])

    respond_to do |format|
      if @workflow_port.update_attributes(params[:workflow_port])
        format.html { redirect_to @workflow_port, :notice => 'Workflow port was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @workflow_port.errors, :status => :unprocessable_entity }
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
    path = @workflow_port.sample_file_actual_path
    filetype = MIME::Types.type_for(path)
    send_file path, :type=> filetype, :name => @workflow_port.sample_file
  end
end
