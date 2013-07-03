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

class WorkflowErrorsControllerTest < ActionController::TestCase
  setup do
    @workflow_error = workflow_errors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workflow_errors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workflow_error" do
    assert_difference('WorkflowError.count') do
      post :create, workflow_error: { error_code: @workflow_error.error_code, error_message: @workflow_error.error_message, error_name: @workflow_error.error_name, error_pattern: @workflow_error.error_pattern, most_recent: @workflow_error.most_recent, my_experiment_id: @workflow_error.my_experiment_id, ports_count: @workflow_error.ports_count, runs_count: @workflow_error.runs_count, workflow_id: @workflow_error.workflow_id }
    end

    assert_redirected_to workflow_error_path(assigns(:workflow_error))
  end

  test "should show workflow_error" do
    get :show, id: @workflow_error
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @workflow_error
    assert_response :success
  end

  test "should update workflow_error" do
    put :update, id: @workflow_error, workflow_error: { error_code: @workflow_error.error_code, error_message: @workflow_error.error_message, error_name: @workflow_error.error_name, error_pattern: @workflow_error.error_pattern, most_recent: @workflow_error.most_recent, my_experiment_id: @workflow_error.my_experiment_id, ports_count: @workflow_error.ports_count, runs_count: @workflow_error.runs_count, workflow_id: @workflow_error.workflow_id }
    assert_redirected_to workflow_error_path(assigns(:workflow_error))
  end

  test "should destroy workflow_error" do
    assert_difference('WorkflowError.count', -1) do
      delete :destroy, id: @workflow_error
    end

    assert_redirected_to workflow_errors_path
  end
end
