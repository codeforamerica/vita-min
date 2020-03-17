class AddNoEligibilityChecksApplyToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :no_eligibility_checks_apply, :integer, default: 0, null: false
  end
end
