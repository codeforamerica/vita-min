class AddContactVerificationToStateIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :email_address_verified_at, :datetime
    add_column :state_file_az_intakes, :phone_number_verified_at, :datetime
    add_column :state_file_ny_intakes, :email_address_verified_at, :datetime
    add_column :state_file_ny_intakes, :phone_number_verified_at, :datetime
  end
end
