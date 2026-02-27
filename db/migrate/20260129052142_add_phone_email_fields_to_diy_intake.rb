class AddPhoneEmailFieldsToDiyIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :diy_intakes, :email_notification_opt_in, :integer, default: 0
    add_column :diy_intakes, :sms_notification_opt_in, :integer, default: 0
    add_column :diy_intakes, :sms_phone_number, :string
  end
end
