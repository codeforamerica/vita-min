class AddMonthsEligibleForGroceryCreditToStateFileIdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :primary_months_eligible_for_grocery_credit, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :spouse_months_eligible_for_grocery_credit, :integer, default: 0, null: false
  end
end
