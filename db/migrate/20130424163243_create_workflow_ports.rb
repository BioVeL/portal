class CreateWorkflowPorts < ActiveRecord::Migration
  def change
    create_table :workflow_ports do |t|
      t.integer :workflow_id
      t.integer :port_type
      t.string :name
      t.string :display_name
      t.string :display_description
      t.integer :order
      t.integer :port_value_type
      t.string :sample_value
      t.string :sample_file
      t.boolean :show
      t.integer :display_control_id

      t.timestamps
    end
  end
end
