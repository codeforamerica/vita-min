class UpdateStateFileDependentEicDisablityAndStudent < ActiveRecord::Migration[7.1]
  def up
    # Create new columns
    add_column :state_file_dependents, :new_eic_disability, :integer, default: 0
    add_column :state_file_dependents, :new_eic_student, :integer, default: 0

    # Backfill new columns
    StateFileDependent.update_all("new_eic_disability = CASE WHEN eic_disability THEN 1 ELSE 2 END")
    StateFileDependent.update_all("new_eic_student = CASE WHEN eic_student THEN 1 ELSE 2 END")

    # Remove old columns
    safety_assured { remove_column :state_file_dependents, :eic_disability }
    safety_assured { remove_column :state_file_dependents, :eic_student }
  end

  def down
    # Add back old columns
    add_column :state_file_dependents, :eic_disability, :boolean
    add_column :state_file_dependents, :eic_student, :boolean

    # Reverse backfill
    StateFileDependent.update_all("eic_disability = CASE WHEN new_eic_disability = 1 THEN TRUE ELSE FALSE END")
    StateFileDependent.update_all("eic_student = CASE WHEN new_eic_student = 2 THEN TRUE ELSE FALSE END")

    # Remove new columns
    remove_column :state_file_dependents, :new_eic_disability
    remove_column :state_file_dependents, :new_eic_student
  end
end
