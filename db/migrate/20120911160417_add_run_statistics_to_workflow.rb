class AddRunStatisticsToWorkflow < ActiveRecord::Migration
  def change
    add_column :workflows, :my_experiment_id, :integer, :default => 0
    add_column :workflows, :average_run, :float, :default => 0
    add_column :workflows, :run_count, :integer, :default => 0    
  end
end
