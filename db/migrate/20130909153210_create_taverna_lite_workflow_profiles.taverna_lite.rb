# This migration comes from taverna_lite (originally 20130829165333)
class CreateTavernaLiteWorkflowProfiles < ActiveRecord::Migration
  def change
    create_table :taverna_lite_workflow_profiles do |t|
      t.string :title
      t.text :description
      t.datetime :created
      t.datetime :modified
      t.integer :license_id
      t.integer :author_id
      t.integer :version

      t.timestamps
    end
  end
end
