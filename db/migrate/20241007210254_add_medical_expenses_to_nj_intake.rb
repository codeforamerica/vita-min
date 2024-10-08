class AddMedicalExpensesToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :medical_expenses, :integer, default: 0, null: false
  end
end
