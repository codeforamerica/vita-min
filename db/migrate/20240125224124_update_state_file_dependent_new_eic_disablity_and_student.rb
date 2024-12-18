class UpdateStateFileDependentNewEicDisablityAndStudent < ActiveRecord::Migration[7.1]
  def up
    # Restore previous column names
    add_column :state_file_dependents, :eic_disability, :integer, default: 0
    add_column :state_file_dependents, :eic_student, :integer, default: 0

    # These should have been in data migrations
    # They caused subsequent failures when new enums were added to the StateFileDependent class
    # See also db/migrate/20240125194731_update_state_file_dependent_eic_disablity_and_student.rb

    # Backfill columns
    # StateFileDependent.update_all("eic_disability = new_eic_disability")
    # StateFileDependent.update_all("eic_student = new_eic_student")

    # Remove new columns
    safety_assured { remove_column :state_file_dependents, :new_eic_disability }
    safety_assured { remove_column :state_file_dependents, :new_eic_student }
  end

  def down
    # Add back new columns
    add_column :state_file_dependents, :new_eic_disability, :integer, default: 0
    add_column :state_file_dependents, :new_eic_student, :integer, default: 0

    # Reverse backfill
    # StateFileDependent.update_all("new_eic_disability = eic_disability")
    # StateFileDependent.update_all("new_eic_student = eic_student")

    # Remove old columns
    remove_column :state_file_dependents, :eic_disability
    remove_column :state_file_dependents, :eic_student
  end
end
