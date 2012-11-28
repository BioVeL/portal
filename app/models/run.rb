class Run < ActiveRecord::Base
  attr_accessible :creation, :description, :end, :expiry, :run_identification, :start, :state, :user_id, :workflow_id

  # every run is linked to a workflow, trough workflow_id
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
end
