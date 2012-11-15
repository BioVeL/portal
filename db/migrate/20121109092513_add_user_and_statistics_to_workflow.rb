class AddUserAndStatisticsToWorkflow < ActiveRecord::Migration
  def change
    add_column :workflows, :slowest_run, :float, :default => 0
    add_column :workflows, :slowest_run_date, :datetime
    add_column :workflows, :fastest_run, :float, :default => 0
    add_column :workflows, :fastest_run_date, :datetime
    add_column :workflows, :user_id, :integer, :default => 0    
    add_column :workflows, :shared, :boolean, :default => false
  end
end
