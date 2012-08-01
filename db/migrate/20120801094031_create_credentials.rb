class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :name
      t.string :description
      t.string :url
      t.string :login
      t.string :password
      t.string :server_type #ts24, rserver 
      t.boolean :in_use, :default => false, :null => false
      t.boolean :default, :default => false, :null => false
    
      t.timestamps
    end
  end
end
