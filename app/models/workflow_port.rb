class WorkflowPort < ActiveRecord::Base
  attr_accessible :display_control_id, :display_description, :display_name, 
     :name, :order, :port_value_type, :sample_file, :sample_value, :show, 
     :workflow_id
  # every port is linked to a workflow, trough workflow_id
  belongs_to :workflow
end
