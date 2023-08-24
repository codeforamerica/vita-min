class AddUspsAddressLateVerificationAttemptsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :usps_address_late_verification_attempts, :integer, default: 0
  end
end
