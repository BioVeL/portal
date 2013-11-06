class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :tavernaservs
    drop_table :credentials
    drop_table :results
    drop_table :interaction_entries
    drop_table :runs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
