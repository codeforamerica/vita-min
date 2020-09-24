class AddIndicesToIntake < ActiveRecord::Migration[6.0]
  def change
    add_index :intakes, :intake_ticket_id
    add_index :intakes, :email_address
    add_index :intakes, :phone_number
    add_index :intakes, :sms_phone_number
  end
end
