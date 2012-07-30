class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :name
      t.string :title
      t.string :description
      t.string :author
      t.string :workflow_file

      t.timestamps
    end
  end
end
