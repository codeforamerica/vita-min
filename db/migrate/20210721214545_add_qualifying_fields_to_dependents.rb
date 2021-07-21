class AddQualifyingFieldsToDependents < ActiveRecord::Migration[6.0]
  def change
    add_column :dependents, :full_time_student, :integer, default: 0, null: false
    add_column :dependents, :permanently_totally_disabled, :integer, default: 0, null: false
    add_column :dependents, :no_ssn_atin, :integer, default: 0, null: false
    add_column :dependents, :provided_over_half_own_support, :integer, default: 0, null: false
    add_column :dependents, :filed_joint_return, :integer, default: 0, null: false
    add_column :dependents, :lived_with_less_than_six_months, :integer, default: 0, null: false
    add_column :dependents, :can_be_claimed_by_other, :integer, default: 0, null: false
    add_column :dependents, :born_in_2020, :integer, default: 0, null: false
    add_column :dependents, :passed_away_2020, :integer, default: 0, null: false
    add_column :dependents, :placed_for_adoption, :integer, default: 0, null: false
    add_column :dependents, :permanent_residence_with_client, :integer, default: 0, null: false
    add_column :dependents, :claim_regardless, :integer, default: 0, null: false
    add_column :dependents, :meets_misc_qualifying_relative_requirements, :integer, default: 0, null: false
  end
end
