class AddIt214ColumnsToStateFileNyIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_ny_intakes, :ny_mailing_street, :string
    add_column :state_file_ny_intakes, :ny_mailing_apartment, :string
    add_column :state_file_ny_intakes, :ny_mailing_city, :string
    add_column :state_file_ny_intakes, :ny_mailing_zip, :string
    add_column :state_file_ny_intakes, :occupied_residence, :integer
    add_column :state_file_ny_intakes, :property_over_limit, :integer
    add_column :state_file_ny_intakes, :public_housing, :integer
    add_column :state_file_ny_intakes, :nursing_home, :integer
    add_column :state_file_ny_intakes, :household_fed_agi, :integer
    add_column :state_file_ny_intakes, :household_ny_additions, :integer
    add_column :state_file_ny_intakes, :household_ssi, :integer
    add_column :state_file_ny_intakes, :household_cash_assistance, :integer
    add_column :state_file_ny_intakes, :household_other_income, :integer
    add_column :state_file_ny_intakes, :household_rent_own, :integer
    add_column :state_file_ny_intakes, :household_rent_amount, :integer
    add_column :state_file_ny_intakes, :household_rent_adjustments, :integer
    add_column :state_file_ny_intakes, :household_own_propety_tax, :integer
    add_column :state_file_ny_intakes, :household_own_assessments, :integer
  end
end
