class MakeMonetaryValuesDecimals < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :charitable_cash_amount, :decimal, precision: 12
    add_column :state_file_az_intakes, :charitable_noncash_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :household_excise_credit_claimed_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :tribal_wages_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :armed_forces_wages_amount, :decimal, precision: 12, scale: 2

    add_column :state_file1099_gs, :unemployment_compensation_amount, :decimal, precision: 12, scale: 2
    add_column :state_file1099_gs, :federal_income_tax_withheld_amount, :decimal, precision: 12, scale: 2
    add_column :state_file1099_gs, :state_income_tax_withheld_amount, :decimal, precision: 12, scale: 2

    add_column :state_file_w2s, :state_wages_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_w2s, :state_income_tax_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_w2s, :local_wages_and_tips_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_w2s, :local_income_tax_amount, :decimal, precision: 12, scale: 2
  end
end

