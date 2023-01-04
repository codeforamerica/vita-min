class Add13614cPage2FieldsToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :had_scholarships, :integer, default: 0, null: false
    add_column :intakes, :had_cash_check_digital_assets, :integer, default: 0, null: false
    add_column :intakes, :has_ssn_of_alimony_recipient, :integer, default: 0, null: false

    add_column :intakes, :contributed_to_ira, :integer, default: 0, null: false
    add_column :intakes, :contributed_to_roth_ira, :integer, default: 0, null: false
    add_column :intakes, :contributed_to_401k, :integer, default: 0, null: false
    add_column :intakes, :contributed_to_other_retirement_account, :integer, default: 0, null: false

    add_column :intakes, :paid_post_secondary_educational_expenses, :integer, default: 0, null: false

    add_column :intakes, :paid_misc_expenses, :integer, default: 0, null: false
    add_column :intakes, :misc_expenses_medical_and_dental, :integer, default: 0, null: false
    add_column :intakes, :misc_expenses_mortgage_interest, :integer, default: 0, null: false
    add_column :intakes, :misc_expenses_taxes, :integer, default: 0, null: false
    add_column :intakes, :misc_expenses_charitable_contributions, :integer, default: 0, null: false

    add_column :intakes, :paid_self_employment_expenses, :integer, default: 0, null: false

    add_column :intakes, :tax_credit_disallowed_year, :integer

    add_column :intakes, :made_estimated_tax_payments_amount, :decimal, precision: 12, scale: 2

    add_column :intakes, :had_capital_loss_carryover, :integer, default: 0, null: false
  end
end
