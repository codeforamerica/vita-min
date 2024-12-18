class AddHealthInsurancePremiumColumnsToIdStateFileIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :has_health_insurance_premium, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :health_insurance_paid_amount, :decimal, precision: 12, scale: 2
  end
end
