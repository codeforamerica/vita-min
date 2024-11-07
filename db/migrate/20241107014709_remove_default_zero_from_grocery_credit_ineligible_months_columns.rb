class RemoveDefaultZeroFromGroceryCreditIneligibleMonthsColumns < ActiveRecord::Migration[7.1]
  def change
    change_column_default(:state_file_id_intakes, :primary_months_ineligible_for_grocery_credit, nil)
    change_column_default(:state_file_id_intakes, :spouse_months_ineligible_for_grocery_credit, nil)
    change_column_default(:state_file_dependents, :id_months_ineligible_for_grocery_credit, nil)
  end
end
