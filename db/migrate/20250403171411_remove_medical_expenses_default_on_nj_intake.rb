class RemoveMedicalExpensesDefaultOnNjIntake < ActiveRecord::Migration[7.1]
  def change
    change_column_null :state_file_nj_intakes, :medical_expenses, true
    change_column_default :state_file_nj_intakes, :medical_expenses, nil
  end
end
