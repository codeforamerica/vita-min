class AddIdHasGroceryCreditIneligibleMonthsToIdIntakeAndStateFileDependents < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :primary_has_grocery_credit_ineligible_months, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :spouse_has_grocery_credit_ineligible_months, :integer, default: 0, null: false
    add_column :state_file_dependents, :id_has_grocery_credit_ineligible_months, :integer, default: 0, null: false

    safety_assured do
      rename_column :state_file_id_intakes, :primary_months_eligible_for_grocery_credit, :primary_months_ineligible_for_grocery_credit
      rename_column :state_file_id_intakes, :spouse_months_eligible_for_grocery_credit, :spouse_months_ineligible_for_grocery_credit
      rename_column :state_file_dependents, :id_months_eligible_for_grocery_credit, :id_months_ineligible_for_grocery_credit

      change_column :state_file_id_intakes, :spouse_months_ineligible_for_grocery_credit, :integer, default: 0, null: true
      change_column :state_file_id_intakes, :primary_months_ineligible_for_grocery_credit, :integer, default: 0, null: true
      change_column :state_file_dependents, :id_months_ineligible_for_grocery_credit, :integer, default: 0, null: true
    end
  end
end
