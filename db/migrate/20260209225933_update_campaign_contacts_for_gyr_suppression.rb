class UpdateCampaignContactsForGyrSuppression < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      remove_column :campaign_contacts, :gyr_2025_preseason_email, :datetime
      remove_column :campaign_contacts, :gyr_2025_preseason_sms, :datetime
    end

    add_column :campaign_contacts, :suppressed_for_gyr_product_year, :integer

    add_index :campaign_contacts, :suppressed_for_gyr_product_year,
              name: "index_campaign_contacts_on_gyr_suppression",
              algorithm: :concurrently
  end
end
