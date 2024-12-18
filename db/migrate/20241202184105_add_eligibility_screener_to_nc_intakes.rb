class AddEligibilityScreenerToNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :eligibility_ed_loan_emp_payment, :integer, default: 0, null: false
    add_column :state_file_nc_intakes, :eligibility_ed_loan_cancelled, :integer, default: 0, null: false
  end
end
