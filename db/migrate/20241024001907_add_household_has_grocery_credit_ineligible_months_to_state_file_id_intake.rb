class AddHouseholdHasGroceryCreditIneligibleMonthsToStateFileIdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :household_has_grocery_credit_ineligible_months, :integer, default: 0, null: false
  end
end
