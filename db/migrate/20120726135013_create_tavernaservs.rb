class CreateTavernaservs < ActiveRecord::Migration
  def change
    create_table :tavernaservs do |t|

      t.timestamps
    end
  end
end
