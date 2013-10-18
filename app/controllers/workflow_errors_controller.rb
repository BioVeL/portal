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
class WorkflowErrorsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :admin_required

  # GET /workflow_errors
  # GET /workflow_errors.json
  def index
    @workflow_errors = WorkflowError.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @workflow_errors }
    end
  end

  # GET /workflow_errors/1
  # GET /workflow_errors/1.json
  def show
    @workflow_error = WorkflowError.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @workflow_error }
    end
  end

  # GET /workflow_errors/new
  # GET /workflow_errors/new.json
  def new
    @workflow_error = WorkflowError.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @workflow_error }
    end
  end

  # GET /workflow_errors/1/edit
  def edit
    @workflow_error = WorkflowError.find(params[:id])
  end

  # POST /workflow_errors
  # POST /workflow_errors.json
  def create
    @workflow_error = WorkflowError.new(params[:workflow_error])

    respond_to do |format|
      if @workflow_error.save
        format.html { redirect_to @workflow_error, :notice => 'Workflow error was successfully created.' }
        format.json { render :json => @workflow_error, :status => :created, :location => @workflow_error }
      else
        format.html { render :action => "new" }
        format.json { render :json => @workflow_error.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workflow_errors/1
  # PUT /workflow_errors/1.json
  def update
    @workflow_error = WorkflowError.find(params[:id])

    respond_to do |format|
      if @workflow_error.update_attributes(params[:workflow_error])
        format.html { redirect_to @workflow_error, :notice => 'Workflow error was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json =>@workflow_error.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workflow_errors/1
  # DELETE /workflow_errors/1.json
  def destroy
    @workflow_error = WorkflowError.find(params[:id])
    @workflow_error.destroy

    respond_to do |format|
      format.html { redirect_to workflow_errors_url }
      format.json { head :no_content }
    end
  end
end
