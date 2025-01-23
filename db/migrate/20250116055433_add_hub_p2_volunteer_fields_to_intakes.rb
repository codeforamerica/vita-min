class AddHubP2VolunteerFieldsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :cv_w2s_cb, :integer, default: 0, null: false 
    add_column :intakes, :cv_w2s_count, :integer

    add_column :intakes, :cv_had_tips_cb, :integer, default: 0, null: false

    add_column :intakes, :cv_1099r_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099r_count, :integer
    add_column :intakes, :cv_1099r_charitable_dist_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099r_charitable_dist_amt, :decimal, precision: 12, scale: 2

    add_column :intakes, :cv_disability_benefits_1099r_or_w2_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_disability_benefits_1099r_or_w2_count, :integer

    add_column :intakes, :cv_ssa1099_rrb1099_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_ssa1099_rrb1099_count, :integer

    add_column :intakes, :cv_1099g_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099g_count, :integer

    add_column :intakes, :cv_local_tax_refund_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_local_tax_refund_amt, :decimal, precision: 12, scale: 2
    add_column :intakes, :cv_itemized_last_year_cb, :integer, default: 0, null: false

    add_column :intakes, :cv_1099int_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099int_count, :integer
    add_column :intakes, :cv_1099div_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099div_count, :integer

    add_column :intakes, :cv_1099b_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099b_count, :integer
    add_column :intakes, :cv_capital_loss_carryover_cb, :integer, default: 0, null: false

    add_column :intakes, :cv_alimony_income_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_alimony_income_amt, :decimal, precision: 12, scale: 2
    add_column :intakes, :cv_alimony_excluded_from_income_cb, :integer, default: 0, null: false

    add_column :intakes, :cv_rental_income_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_rental_expense_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_rental_expense_amt, :decimal, precision: 12, scale: 2

    add_column :intakes, :cv_w2g_or_other_gambling_winnings_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_w2g_or_other_gambling_winnings_count, :integer

    add_column :intakes, :cv_schedule_c_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099misc_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099misc_count, :integer
    add_column :intakes, :cv_1099nec_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099nec_count, :integer
    add_column :intakes, :cv_1099k_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_1099k_count, :integer
    add_column :intakes, :cv_other_income_reported_elsewhere_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_schedule_c_expenses_cb, :integer, default: 0, null: false
    add_column :intakes, :cv_schedule_c_expenses_amt, :decimal, precision: 12, scale: 2

    add_column :intakes, :cv_other_income_cb, :integer, default: 0, null: false

    add_column :intakes, :cv_p2_notes_comments, :string
  end
end
