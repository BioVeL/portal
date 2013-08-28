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

require 'test_helper'

class InteractionEntriesControllerTest < ActionController::TestCase
  setup do
    @interaction_entry = interaction_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:interaction_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create interaction_entry" do
    assert_difference('InteractionEntry.count') do
      post :create, :interaction_entry => {
        :author_name => @interaction_entry.author_name,
        :content => @interaction_entry.content,
        :href => @interaction_entry.href,
        :in_reply_to => @interaction_entry.in_reply_to,
        :input_data => @interaction_entry.input_data,
        :interaction_id => @interaction_entry.interaction_id,
        :published => @interaction_entry.published,
        :response => @interaction_entry.response,
        :result_data => @interaction_entry.result_data,
        :result_status => @interaction_entry.result_status,
        :run_id => @interaction_entry.run_id,
        :taverna_interaction_id => @interaction_entry.taverna_interaction_id,
        :title => @interaction_entry.title,
        :updated => @interaction_entry.updated
      }
    end

    assert_redirected_to interaction_entry_path(assigns(:interaction_entry))
  end

  test "should show interaction_entry" do
    get :show, :id => @interaction_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @interaction_entry
    assert_response :success
  end

  test "should update interaction_entry" do
    put :update, :id => @interaction_entry, :interaction_entry => {
      :author_name => @interaction_entry.author_name,
      :content => @interaction_entry.content,
      :href => @interaction_entry.href,
      :in_reply_to => @interaction_entry.in_reply_to,
      :input_data => @interaction_entry.input_data,
      :interaction_id => @interaction_entry.interaction_id,
      :published => @interaction_entry.published,
      :response => @interaction_entry.response,
      :result_data => @interaction_entry.result_data,
      :result_status => @interaction_entry.result_status,
      :run_id => @interaction_entry.run_id,
      :taverna_interaction_id => @interaction_entry.taverna_interaction_id,
      :title => @interaction_entry.title,
      :updated => @interaction_entry.updated
    }
    assert_redirected_to interaction_entry_path(assigns(:interaction_entry))
  end

  test "should destroy interaction_entry" do
    assert_difference('InteractionEntry.count', -1) do
      delete :destroy, :id => @interaction_entry
    end

    assert_redirected_to interaction_entries_path
  end
end
