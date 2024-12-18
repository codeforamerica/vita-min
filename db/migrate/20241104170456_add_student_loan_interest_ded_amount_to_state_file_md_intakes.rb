class AddStudentLoanInterestDedAmountToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :primary_student_loan_interest_ded_amount, :decimal, precision: 12, scale: 2, null: false, default: 0
    add_column :state_file_md_intakes, :spouse_student_loan_interest_ded_amount, :decimal, precision: 12, scale: 2, null: false, default: 0
  end
end
