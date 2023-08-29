class AddMore1040ColumnsToAzIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_az_intakes, :filing_status, :integer
    add_column :state_file_az_intakes, :claimed_as_dep, :integer
    add_column :state_file_az_intakes, :phone_daytime, :string
    add_column :state_file_az_intakes, :phone_daytime_area_code, :string
    add_column :state_file_az_intakes, :primary_middle_name, :string

    add_column :state_file_az_intakes, :spouse_first_name, :string
    add_column :state_file_az_intakes, :spouse_last_name, :string
    add_column :state_file_az_intakes, :spouse_middle_initial, :string
    add_column :state_file_az_intakes, :spouse_dob, :date
    add_column :state_file_az_intakes, :spouse_ssn, :string
    add_column :state_file_az_intakes, :spouse_occupation, :string

    add_column :state_file_az_intakes, :mailing_apartment, :string

    add_column :state_file_az_intakes, :fed_wages, :integer
    add_column :state_file_az_intakes, :fed_taxable_income, :integer
    add_column :state_file_az_intakes, :fed_unemployment, :integer
    add_column :state_file_az_intakes, :fed_taxable_ssb, :integer
    add_column :state_file_az_intakes, :total_fed_adjustments_identify, :string
    add_column :state_file_az_intakes, :total_fed_adjustments, :integer
    add_column :state_file_az_intakes, :total_ny_tax_withheld, :integer
  end
end
