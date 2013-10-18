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
# BioVeL Portal is a prototype interface to Taverna Server which is provided to
# support easy inspection and execution of workflows.
#
# For more details see http://www.biovel.eu
#
# BioVeL is funded by the European Commission 7th Framework Programme (FP7),
# through the grant agreement number 283359.
class Run < ActiveRecord::Base
  attr_accessible :creation, :description, :end, :expiry, :run_identification,
    :start, :state, :user_id, :workflow_id

  # Every run is owned by a user and linked to a workflow
  belongs_to :user
  belongs_to :workflow

  # a run can have many results
  has_many :results

  # Validate that inputs have been provided
  def validate
    validate_inputs
  end
  def validate_inputs
    workflow = Workflow.find(workflow_id)
  end

  def delete_results
    Result.delete_files(id)
  end
  def get_error_codes
    # check if run has errors
    bad_results =
      Result.where("filetype=? AND run_id = ?",'error', id)
    error_codes =
      TavernaLite::WorkflowError.where('workflow_id = ?',workflow_id)
    # verify each error to check if it has been handled
    samples = []
    collect = {}
    bad_results.each do |ind_result|
      is_new = true
      error_codes.each do |ind_error|
        File.open(ind_result.result_filename) do |f|
          f.each_line do |line|
            if line =~ /#{ind_error.pattern}/ then
              collect[ind_result.name] = ind_error
              is_new = false
            end
          end
        end
      end
      if is_new then
        example_value = IO.read(ind_result.result_filename)
        # 1 Filer duplicate outputs - Sometimes the same error happens several times
        unless samples.include?(example_value)
          new_error = TavernaLite::WorkflowError.new
          new_error.error_code = "E_" + (100000+ind_result.run_id).to_s + "_" + ind_result.name
          new_error.message = "Workflow run produced an error for " + ind_result.name
          new_error.name = ind_result.name
          new_error.pattern = example_value
          new_error.workflow_id = id
          collect[ind_result.name] = new_error
          samples << example_value
        end
      end
    end
    return collect
  end

end
