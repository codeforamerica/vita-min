# == Schema Information
#
# Table name: provider_scrapes
#
#  id             :bigint           not null, primary key
#  archived_count :integer          default(0), not null
#  changed_count  :integer          default(0), not null
#  created_count  :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ProviderScrape < ApplicationRecord
  has_many :vita_providers, foreign_key: :last_scrape

  def self.get_recent_or_create
    where("created_at >= ?", 12.hours.ago).first || create
  end

  def handle_irs_provider_data(data)
    existing_provider = VitaProvider.unscraped_by(self).find_by(irs_id: data[:irs_id])
    if existing_provider.present?
      if existing_provider.same_as_irs_result?(data) && existing_provider.is_listed?
        mark_unchanged_provider_as_scraped(existing_provider)
      else
        change_existing_provider(existing_provider, data)
      end
    else
      add_new_provider(data)
    end
  end

  def archive_all_unscraped_providers
    # update_all skips save callbacks and does not change updated_at, so we need to set it manually
    result = VitaProvider.listed.unscraped_by(self).update_all(
      last_scrape_id: self.id,
      archived: true,
      updated_at: Time.now
    )
    update(archived_count: archived_count + result)
  end

  private

  def mark_unchanged_provider_as_scraped(provider)
    provider.update(last_scrape: self)
  end

  def change_existing_provider(provider, new_data)
    provider.last_scrape = self
    provider.archived = false
    increment!(:changed_count) if provider.update_with_irs_data(new_data)
  end

  def add_new_provider(new_data)
    provider = VitaProvider.new(last_scrape: self)
    increment!(:created_count) if provider.update_with_irs_data(new_data)
  end
end
