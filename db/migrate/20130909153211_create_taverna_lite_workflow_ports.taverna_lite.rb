# This migration comes from taverna_lite (originally 20130829165339)
class CreateTavernaLiteWorkflowPorts < ActiveRecord::Migration
  def change
    create_table :taverna_lite_workflow_ports do |t|
      t.integer :workflow_id
      t.integer :port_type_id
      t.string :name
      t.string :display_name
      t.text :description
      t.text :display_description
      t.integer :order

      t.timestamps
    end
  end
end
