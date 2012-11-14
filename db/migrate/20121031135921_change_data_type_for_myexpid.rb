class ChangeDataTypeForMyexpid < ActiveRecord::Migration
  def up
    change_table :workflows do |t|
      t.change :my_experiment_id, :string
    end
  end

  def down
    change_table :workflows do |t|
      t.change :my_experiment_id, :integer
    end
  end
end
