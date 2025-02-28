class AddRetirementWarningContinueConfirmation < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :eligibility_retirement_warning_continue, :integer, default: 0
  end
end
