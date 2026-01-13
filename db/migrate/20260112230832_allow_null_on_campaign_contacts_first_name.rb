class AllowNullOnCampaignContactsFirstName < ActiveRecord::Migration[7.1]
  def change
    change_column_null :campaign_contacts, :first_name, true
  end
end
