class UpdateStateFileDependentEicDisablityAndStudent < ActiveRecord::Migration[7.1]
  class ModifyColumnsInStateFileDependents < ActiveRecord::Migration[6.0]
    def up
      # Create new columns
      add_column :state_file_dependents, :new_eic_disability, :integer, default: 0
      add_column :state_file_dependents, :new_eic_student, :integer, default: 0

      # Backfill data from old columns to new columns
      StateFileDependent.update_all("new_eic_disability = CASE WHEN eic_disability THEN 1 ELSE 0 END")
      StateFileDependent.update_all("new_eic_disability = CASE WHEN eic_disability THEN 1 WHEN eic_student THEN 2 ELSE 0 END")

      StateFileDependent.update_all("new_eic_student = CASE WHEN eic_student THEN 2 ELSE 0 END")

      # Remove old columns
      remove_column :state_file_dependents, :eic_disability
      remove_column :state_file_dependents, :eic_student

      # Rename new columns to new columns
      rename_column :state_file_dependents, :new_eic_disability, :eic_disability
      rename_column :state_file_dependents, :new_eic_student, :eic_student
    end

    def down
      # Reverse the migration if needed
      rename_column :state_file_dependents, :eic_disability, :new_eic_disability
      rename_column :state_file_dependents, :eic_student, :new_eic_student

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
end
