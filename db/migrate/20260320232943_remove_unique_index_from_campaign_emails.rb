class RemoveUniqueIndexFromCampaignEmails < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    remove_index :campaign_emails, name: "index_campaign_emails_on_contact_id_and_message_name"

    add_index :campaign_emails,
              [:campaign_contact_id, :message_name],
              name: "index_campaign_emails_on_contact_id_and_message_name",
              algorithm: :concurrently
  end

  def down
    remove_index :campaign_emails, name: "index_campaign_emails_on_contact_id_and_message_name"

    add_index :campaign_emails,
              [:campaign_contact_id, :message_name],
              name: "index_campaign_emails_on_contact_id_and_message_name",
              unique: true,
              algorithm: :concurrently
  end
end
