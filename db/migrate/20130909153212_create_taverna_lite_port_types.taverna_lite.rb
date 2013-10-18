# This migration comes from taverna_lite (originally 20130829165345)
class CreateTavernaLitePortTypes < ActiveRecord::Migration
  def change
    create_table :taverna_lite_port_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
