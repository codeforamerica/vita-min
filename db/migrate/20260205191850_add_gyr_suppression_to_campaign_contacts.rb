class AddGyrSuppressionToCampaignContacts < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :campaign_contacts, :suppressed_for_gyr_product_year, :integer
    add_index :campaign_contacts, [:suppressed_for_gyr_product_year],
              name: "index_campaign_contacts_on_gyr_suppression", algorithm: :concurrently
  end
end
