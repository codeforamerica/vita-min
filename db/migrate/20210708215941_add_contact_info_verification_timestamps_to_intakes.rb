class AddContactInfoVerificationTimestampsToIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :email_address_verified_at, :datetime
    add_column :intakes, :sms_phone_number_verified_at, :datetime
  end
end
