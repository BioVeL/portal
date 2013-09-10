# This migration comes from taverna_lite (originally 20130902142706)
class AddDisplayControlIdToTavernaLiteWorkflowPorts < ActiveRecord::Migration
  def change
    add_column :taverna_lite_workflow_ports, :display_control_id, :integer
  end
end
