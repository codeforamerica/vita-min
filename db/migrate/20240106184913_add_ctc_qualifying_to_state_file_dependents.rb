class AddCtcQualifyingToStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :ctc_qualifying, :boolean
  end
end
