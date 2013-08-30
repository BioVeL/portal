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
class CredentialsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :admin_required

  # GET /credentials
  # GET /credentials.json
  def index
    @credentials = Credential.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @credentials }
    end
  end

  # GET /credentials/1
  # GET /credentials/1.json
  def show
    @credential = Credential.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @credential }
    end
  end

  # GET /credentials/new
  # GET /credentials/new.json
  def new
    @credential = Credential.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @credential }
    end
  end

  # GET /credentials/1/edit
  def edit
    @credential = Credential.find(params[:id])
  end

  # POST /credentials
  # POST /credentials.json
  def create
    @credential = Credential.new(params[:credential])

    respond_to do |format|
      if @credential.save
        format.html { redirect_to @credential, :notice => 'Credential was successfully created.' }
        format.json { render :json => @credential, :status => :created, :location => @credential }
      else
        format.html { render :action => "new" }
        format.json { render :json => @credential.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /credentials/1
  # PUT /credentials/1.json
  def update
    @credential = Credential.find(params[:id])

    respond_to do |format|
      if @credential.update_attributes(params[:credential])
        format.html { redirect_to @credential, :notice => 'Credential was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @credential.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credentials/1
  # DELETE /credentials/1.json
  def destroy
    @credential = Credential.find(params[:id])
    @credential.destroy

    respond_to do |format|
      format.html { redirect_to credentials_url }
      format.json { head :no_content }
    end
  end
end
