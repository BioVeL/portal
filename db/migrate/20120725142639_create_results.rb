class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :name
      t.string :filetype
      t.integer :depth
      t.integer :run_id
      t.string :filepath

      t.timestamps
    end
  end
end
