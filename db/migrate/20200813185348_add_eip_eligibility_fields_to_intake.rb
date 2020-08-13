class AddEipEligibilityFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :claimed_by_another, :integer, default: 0, null: false
    add_column :intakes, :already_applied_for_stimulus, :integer, default: 0, null: false
    add_column :intakes, :no_ssn, :integer, default: 0, null: false
  end
end
