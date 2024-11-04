class AddStudentLoanInterestDedAmountToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :student_loan_interest_ded_amount_cents, :bigint, default: 0, null: false
    add_column :state_file_md_intakes, :spouse_student_loan_interest_ded_amount_cents, :bigint, default: 0, null: false
  end
end
