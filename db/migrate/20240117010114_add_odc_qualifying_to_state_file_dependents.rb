class AddOdcQualifyingToStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :odc_qualifying, :boolean
  end
end
