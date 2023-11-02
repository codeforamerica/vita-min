class AddHasPriorLastNamesToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :has_prior_last_names, :integer, default: 0, null: false
  end
end
