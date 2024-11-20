class AddCollegeDependentExemptionsToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_dependents, :nj_dependent_attends_accredited_program, :integer, default: 0, null: false
    add_column :state_file_dependents, :nj_dependent_enrolled_full_time, :integer, default: 0, null: false
    add_column :state_file_dependents, :nj_dependent_five_months_in_college, :integer, default: 0, null: false
    add_column :state_file_dependents, :nj_filer_pays_tuition_for_dependent, :integer, default: 0, null: false
  end
end