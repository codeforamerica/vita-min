class AddStudentToStateFileDependent < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :eic_qualifying, :boolean
    add_column :state_file_dependents, :eic_student, :boolean
    add_column :state_file_dependents, :eic_disability, :boolean
  end
end
