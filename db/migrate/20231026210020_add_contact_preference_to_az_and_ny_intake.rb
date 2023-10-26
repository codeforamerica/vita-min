class AddContactPreferenceToAzAndNyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :contact_preference, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :contact_preference, :integer, default: 0, null: false
  end
end
