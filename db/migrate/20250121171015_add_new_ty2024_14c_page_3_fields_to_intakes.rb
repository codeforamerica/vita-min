class AddNewTy202414cPage3FieldsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :cv_1098_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1098_count, :integer
    add_column :intakes, :cv_med_expense_standard_deduction_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_med_expense_itemized_deduction_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1098e_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_child_dependent_care_credit_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_edu_expenses_deduction_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_edu_expenses_deduction_amt, :decimal, precision: 12, scale: 2
    add_column :intakes, :cv_paid_alimony_w_spouse_ssn_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_paid_alimony_w_spouse_ssn_amt, :decimal, precision: 12, scale: 2
    add_column :intakes, :cv_alimony_income_adjustment_yn_cb, :integer, default: 0, null: false # (yes/no)
    add_column :intakes, :cv_taxable_scholarship_income_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1098t_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_edu_credit_or_tuition_deduction_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099s_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_hsa_contrib_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_hsa_distrib_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1095a_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_energy_efficient_home_improv_credit_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099c_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099a_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_disaster_relief_impacts_return_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_eitc_ctc_aotc_hoh_disallowed_in_a_prev_yr_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_tax_credit_disallowed_reason, :string
    add_column :intakes, :cv_eligible_for_litc_referral_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_estimated_tax_payments_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_estimated_tax_payments_amt, :decimal, precision: 12, scale: 2
    add_column :intakes, :cv_last_years_refund_applied_to_this_yr_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_last_years_refund_applied_to_this_yr_amt, :decimal, precision: 12, scale: 2
    add_column :intakes, :cv_last_years_return_available_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_14c_page_3_notes_part_1, :string
    add_column :intakes, :cv_14c_page_3_notes_part_2, :string
    add_column :intakes, :cv_14c_page_3_notes_part_3, :string
  end
end
