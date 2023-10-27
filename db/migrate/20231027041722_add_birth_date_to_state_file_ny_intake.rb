class AddBirthDateToStateFileNyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :primary_birth_date, :date
    add_column :state_file_ny_intakes, :spouse_birth_date, :date
  end
end
