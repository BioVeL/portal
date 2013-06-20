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
class InteractionEntriesController < ApplicationController
  before_filter :admin_required
  # GET /interaction_entries
  # GET /interaction_entries.json
  def index
    @interaction_entries = InteractionEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @interaction_entries }
    end
  end

  # GET /interaction_entries/1
  # GET /interaction_entries/1.json
  def show
    @interaction_entry = InteractionEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @interaction_entry }
    end
  end

  # GET /interaction_entries/new
  # GET /interaction_entries/new.json
  def new
    @interaction_entry = InteractionEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @interaction_entry }
    end
  end

  # GET /interaction_entries/1/edit
  def edit
    @interaction_entry = InteractionEntry.find(params[:id])
  end

  # POST /interaction_entries
  # POST /interaction_entries.json
  def create
    @interaction_entry = InteractionEntry.new(params[:interaction_entry])

    respond_to do |format|
      if @interaction_entry.save
        format.html { redirect_to @interaction_entry, :notice => 'Interaction entry was successfully created.' }
        format.json { render :json => @interaction_entry, :status => :created, :location => @interaction_entry }
      else
        format.html { render :action => "new" }
        format.json { render :json => @interaction_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /interaction_entries/1
  # PUT /interaction_entries/1.json
  def update
    @interaction_entry = InteractionEntry.find(params[:id])

    respond_to do |format|
      if @interaction_entry.update_attributes(params[:interaction_entry])
        format.html { redirect_to @interaction_entry, :notice => 'Interaction entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @interaction_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /interaction_entries/1
  # DELETE /interaction_entries/1.json
  def destroy
    @interaction_entry = InteractionEntry.find(params[:id])
    @interaction_entry.destroy

    respond_to do |format|
      format.html { redirect_to interaction_entries_url }
      format.json { head :no_content }
    end
  end
end
