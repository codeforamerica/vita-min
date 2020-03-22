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
end
