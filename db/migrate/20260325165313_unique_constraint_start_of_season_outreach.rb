class UniqueConstraintStartOfSeasonOutreach < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_index :campaign_emails,
              [:campaign_contact_id, :message_name],
              unique: true,
              where: "message_name = 'start_of_season_outreach'",
              name: "index_unique_start_of_season_outreach_per_contact",
              algorithm: :concurrently
  end

  def down
    remove_index :campaign_emails,
                 name: "index_unique_start_of_season_outreach_per_contact"
  end
end
