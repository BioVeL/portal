# This migration comes from taverna_lite (originally 20130924095717)
class CreateTavernaLiteWorkflowComponents < ActiveRecord::Migration
  def change
    create_table :taverna_lite_workflow_components do |t|
      t.integer :workflow_id
      t.integer :license_id
      t.integer :version
      t.string :family
      t.string :name
      t.string :registry

      t.timestamps
    end
  end
end
