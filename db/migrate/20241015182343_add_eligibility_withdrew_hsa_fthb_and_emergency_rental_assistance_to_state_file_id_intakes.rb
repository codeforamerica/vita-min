class AddEligibilityWithdrewHsaFthbAndEmergencyRentalAssistanceToStateFileIdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_id_intakes, :eligibility_withdrew_msa_fthb, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :eligibility_emergency_rental_assistance, :integer, default: 0, null: false
  end
end
