class AddScheduledSendAtToCampaignEmail < ActiveRecord::Migration[7.1]
  def change
    add_column :campaign_emails, :scheduled_send_at, :datetime
  end
end
