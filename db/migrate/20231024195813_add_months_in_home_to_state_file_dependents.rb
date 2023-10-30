class AddMonthsInHomeToStateFileDependents < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_dependents, :months_in_home, :integer
  end
end
