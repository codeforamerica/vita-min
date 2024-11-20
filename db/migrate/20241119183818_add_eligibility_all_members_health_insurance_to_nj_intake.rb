class AddEligibilityAllMembersHealthInsuranceToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :eligibility_all_members_health_insurance, :integer, default: 0, null: false
  end
end
