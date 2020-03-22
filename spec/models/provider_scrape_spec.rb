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

require "rails_helper"

describe ProviderScrape do
  describe "default values" do
    it "sets default values" do
      scrape = ProviderScrape.new
      expect(scrape.changed_count).to eq 0
      expect(scrape.archived_count).to eq 0
      expect(scrape.created_count).to eq 0
    end
  end

  describe ".get_recent_or_create" do
    context "when there is a scrape in the past 12 hours" do
      let!(:most_recent_scrape) { create :provider_scrape, created_at: 11.hours.ago }

      it "returns the most_recent scrape" do
        expect do
          result = ProviderScrape.get_recent_or_create
          expect(result).to eq most_recent_scrape
        end.to_not change(ProviderScrape, :count)
      end
    end

    context "when there is no scrape in the past 12 hours" do
      let!(:most_recent_scrape) { create :provider_scrape, created_at: 13.hours.ago }

      it "creates a new scrape" do
        expect do
          result = ProviderScrape.get_recent_or_create
          expect(result).to_not eq most_recent_scrape
        end.to change(ProviderScrape, :count).by 1
      end
    end
  end
end
