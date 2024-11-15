 class AddIdMonthsEligibleForGroceryCreditToStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :id_months_eligible_for_grocery_credit, :integer, default: 0, null: false
  end
end
