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
# BioVeL Taverna Lite  is a prototype interface to Taverna Server which is
# provided to support easy inspection and execution of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.

class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => :new
  before_filter :check_user, :only => [:edit, :update]
  before_filter :admin_required, :only => :index

  before_filter :find_user, :except => :index
  before_filter :find_users, :only => :index

  def index
    guest = User.new(:name=>'Guest') #the guest user
    guest.id = 0
    guest.user_statistic = UserStatistic.find_or_create_by_id(0)
    @users << guest
  end

  # GET /workflows/1/edit
  def edit
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to home_or_users, :notice => 'The user profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @workflow.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def find_users
    @users = User.all
  end

  def check_user
    find_user unless defined?(@user)

    unless current_user == @user || current_user.admin?
      flash[:error] = "You can only edit your own profile!"
      begin
        redirect_to :back
      rescue ActionController::RedirectBackError
        redirect_to root_path
      end
    end
  end

  def home_or_users
    current_user.admin? ? users_path : root_path
  end

end
