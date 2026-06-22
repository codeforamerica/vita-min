class AddEmailUnsubscribedAtToIntakes < ActiveRecord::Migration[7.2]
  def change
    add_column :intakes, :email_unsubscribed_at, :datetime
    add_column :intakes, :sms_unsubscribed_at, :datetime
  end
end
