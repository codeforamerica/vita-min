class RenameStateFileAzColumns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :state_file_az_intakes, :birth_date, :primary_dob
      rename_column :state_file_az_intakes, :city, :mailing_city
      rename_column :state_file_az_intakes, :ssn, :primary_ssn
      rename_column :state_file_az_intakes, :street_address, :mailing_street
      rename_column :state_file_az_intakes, :zip_code, :mailing_zip
    end
  end
end
