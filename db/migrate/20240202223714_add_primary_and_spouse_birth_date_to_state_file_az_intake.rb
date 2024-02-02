class AddPrimaryAndSpouseBirthDateToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :primary_birth_date, :date
    add_column :state_file_az_intakes, :spouse_birth_date, :date
  end
end
