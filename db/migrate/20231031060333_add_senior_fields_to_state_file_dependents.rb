class AddSeniorFieldsToStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :needed_assistance, :integer, default: 0, null: false
    add_column :state_file_dependents, :passed_away, :integer, default: 0, null: false
  end
end
