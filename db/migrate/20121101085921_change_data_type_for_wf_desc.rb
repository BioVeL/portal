class ChangeDataTypeForWfDesc < ActiveRecord::Migration
  def up
    change_table :workflows do |t|
      t.change :description, :text
    end
  end

  def down
    change_table :workflows do |t|
      t.change :description, :text
    end
  end
end
