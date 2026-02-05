class RemoveGyr2025PreseasonColumnsFromCampaignContacts < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :campaign_contacts, :gyr_2025_preseason_email, :datetime
      remove_column :campaign_contacts, :gyr_2025_preseason_sms, :datetime
    end
  end
end
