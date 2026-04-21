class AddDomainIndexToCampaignEmails < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<~SQL
        CREATE INDEX CONCURRENTLY idx_campaign_emails_on_domain
        ON campaign_emails (lower(split_part(to_email, '@', 2)));
      SQL
    end
  end

  def down
    safety_assured do
      execute <<~SQL
        DROP INDEX CONCURRENTLY IF EXISTS idx_campaign_emails_on_domain;
      SQL
    end
  end
end