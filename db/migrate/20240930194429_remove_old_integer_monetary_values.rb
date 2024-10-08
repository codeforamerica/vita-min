class RemoveOldIntegerMonetaryValues < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_az_intakes, :armed_forces_wages, :integer
      remove_column :state_file_az_intakes, :charitable_cash, :integer
      remove_column :state_file_az_intakes, :charitable_noncash, :integer
      remove_column :state_file_az_intakes, :household_excise_credit_claimed_amt, :integer
      remove_column :state_file_az_intakes, :tribal_wages, :integer

      remove_column :state_file_w2s, :local_income_tax_amt, :integer
      remove_column :state_file_w2s, :local_wages_and_tips_amt, :integer
      remove_column :state_file_w2s, :state_income_tax_amt, :integer
      remove_column :state_file_w2s, :state_wages_amt, :integer

      remove_column :state_file1099_gs, :federal_income_tax_withheld, :integer
      remove_column :state_file1099_gs, :state_income_tax_withheld, :integer
      remove_column :state_file1099_gs, :unemployment_compensation, :integer
    end
  end
end
