class AddColumnsToIntake < ActiveRecord::Migration[5.2]
  def change
    rename_column :intakes, :has_wages, :had_wages
    remove_column :intakes, :has_scholarship_income, :integer

    add_column :intakes, :job_count, :integer
    add_column :intakes, :had_tips, :integer, default: 0, null: false
    add_column :intakes, :had_retirement_income, :integer, default: 0, null: false
    add_column :intakes, :had_social_security_income, :integer, default: 0, null: false
    add_column :intakes, :had_unemployment_income, :integer, default: 0, null: false
    add_column :intakes, :had_disability_income, :integer, default: 0, null: false
    add_column :intakes, :had_interest_income, :integer, default: 0, null: false
    add_column :intakes, :had_asset_sale_income, :integer, default: 0, null: false
    add_column :intakes, :reported_asset_sale_loss, :integer, default: 0, null: false
    add_column :intakes, :received_alimony, :integer, default: 0, null: false
    add_column :intakes, :had_rental_income, :integer, default: 0, null: false
    add_column :intakes, :had_farm_income, :integer, default: 0, null: false
    add_column :intakes, :had_gambling_income, :integer, default: 0, null: false
    add_column :intakes, :had_local_tax_refund, :integer, default: 0, null: false
    add_column :intakes, :had_self_employment_income, :integer, default: 0, null: false
    add_column :intakes, :reported_self_employment_loss, :integer, default: 0, null: false
    add_column :intakes, :had_other_income, :integer, default: 0, null: false
    add_column :intakes, :other_income_types, :string
    add_column :intakes, :paid_mortgage_interest, :integer, default: 0, null: false
    add_column :intakes, :paid_local_tax, :integer, default: 0, null: false
    add_column :intakes, :paid_medical_expenses, :integer, default: 0, null: false
    add_column :intakes, :paid_charitable_contributions, :integer, default: 0, null: false
    add_column :intakes, :paid_student_loan_interest, :integer, default: 0, null: false
    add_column :intakes, :paid_dependent_care, :integer, default: 0, null: false
    add_column :intakes, :paid_retirement_contributions, :integer, default: 0, null: false
    add_column :intakes, :paid_school_supplies, :integer, default: 0, null: false
    add_column :intakes, :paid_alimony, :integer, default: 0, null: false
    add_column :intakes, :had_student_in_family, :integer, default: 0, null: false
    add_column :intakes, :sold_a_home, :integer, default: 0, null: false
    add_column :intakes, :had_hsa, :integer, default: 0, null: false
    add_column :intakes, :bought_health_insurance, :integer, default: 0, null: false
    add_column :intakes, :received_homebuyer_credit, :integer, default: 0, null: false
    add_column :intakes, :had_debt_forgiven, :integer, default: 0, null: false
    add_column :intakes, :had_disaster_loss, :integer, default: 0, null: false
    add_column :intakes, :adopted_child, :integer, default: 0, null: false
    add_column :intakes, :had_tax_credit_disallowed, :integer, default: 0, null: false
    add_column :intakes, :received_irs_letter, :integer, default: 0, null: false
    add_column :intakes, :made_estimated_tax_payments, :integer, default: 0, null: false
    add_column :intakes, :additional_info, :string
  end
end
