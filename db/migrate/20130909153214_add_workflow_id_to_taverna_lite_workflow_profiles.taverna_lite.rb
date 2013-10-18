# This migration comes from taverna_lite (originally 20130902133741)
class AddWorkflowIdToTavernaLiteWorkflowProfiles < ActiveRecord::Migration
  def change
    add_column :taverna_lite_workflow_profiles, :workflow_id, :integer
  end
end
