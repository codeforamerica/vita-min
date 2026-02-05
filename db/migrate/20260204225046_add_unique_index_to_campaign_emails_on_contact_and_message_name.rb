class AddUniqueIndexToCampaignEmailsOnContactAndMessageName < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :campaign_emails, [:campaign_contact_id, :message_name],
              unique: true, name: "index_campaign_emails_on_contact_id_and_message_name",
              algorithm: :concurrently
  end
end
