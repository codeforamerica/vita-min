class AddDiyIntakeIdsToCampaignContact < ActiveRecord::Migration[7.1]
  def change
    add_column :campaign_contacts, :diy_intake_ids, :integer, array: true, default: []
    add_column :campaign_contacts, :latest_diy_intake_at, :datetime
  end
end
