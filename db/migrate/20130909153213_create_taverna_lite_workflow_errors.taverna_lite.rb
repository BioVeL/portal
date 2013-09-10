# This migration comes from taverna_lite (originally 20130829165409)
class CreateTavernaLiteWorkflowErrors < ActiveRecord::Migration
  def change
    create_table :taverna_lite_workflow_errors do |t|
      t.integer :workflow_id
      t.string :error_code
      t.string :name
      t.string :pattern
      t.string :message
      t.integer :run_count
      t.integer :port_count

      t.timestamps
    end
  end
end
