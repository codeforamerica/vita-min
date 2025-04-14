class AddRetirementIncomeOffboardingFieldToStateFileIdIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :clicked_to_file_with_other_service_at, :datetime
  end
end
