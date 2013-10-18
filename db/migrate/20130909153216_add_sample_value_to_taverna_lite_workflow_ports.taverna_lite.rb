# This migration comes from taverna_lite (originally 20130902142953)
class AddSampleValueToTavernaLiteWorkflowPorts < ActiveRecord::Migration
  def change
    add_column :taverna_lite_workflow_ports, :sample_value, :string
    add_column :taverna_lite_workflow_ports, :sample_file, :string
    add_column :taverna_lite_workflow_ports, :sample_file_type, :string
    add_column :taverna_lite_workflow_ports, :show, :boolean
  end
end
