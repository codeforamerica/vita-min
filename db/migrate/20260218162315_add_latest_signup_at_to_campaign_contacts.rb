class AddLatestSignupAtToCampaignContacts < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :campaign_contacts, :latest_signup_at, :datetime
    add_column :campaign_contacts, :latest_gyr_intake_at, :datetime

    add_index  :campaign_contacts, :latest_signup_at, algorithm: :concurrently
    add_index  :campaign_contacts, :latest_gyr_intake_at, algorithm: :concurrently
  end
end
