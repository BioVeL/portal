class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.string :run_identification
      t.string :state
      t.datetime :creation
      t.datetime :start
      t.datetime :end
      t.datetime :expiry
      t.integer :workflow_id
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end
end
