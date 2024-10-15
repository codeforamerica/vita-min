class RemoveEligibilityLivedInStateAndOutOfStateIncomeFromStateFileIdIntakes < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_id_intakes, :eligibility_lived_in_state
      remove_column :state_file_id_intakes, :eligibility_out_of_state_income
    end
  end
end
