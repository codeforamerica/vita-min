class AddSmsPhoneNumberToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :sms_phone_number, :string
  end
end
