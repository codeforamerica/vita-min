class AddUnsubscribedAtToCampaignContacts < ActiveRecord::Migration[7.2]
  def change
    add_column :campaign_contacts, :email_unsubscribed_at, :datetime
    add_column :campaign_contacts, :sms_unsubscribed_at, :datetime
  end
end
