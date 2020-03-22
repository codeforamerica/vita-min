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

  describe "#handle_irs_provider_data" do
    let(:scrape) { create :provider_scrape, changed_count: 0, created_count: 0, archived_count: 0 }
    let(:prior_scrape) { create :provider_scrape }
    let(:provider_data) do
      {
        name: "Tax Help Palace",
        irs_id: "100",
        provider_details: nil,
        dates: nil,
        languages: ["Spanish", "English"],
        appointment_info: "Required",
        hours: nil,
        lat_long: ["29.710592", "-95.496816"],
      }
    end

    context "with new data and no matching irs_id" do
      it "creates a new record and increments created_count" do
        expect do
          scrape.handle_irs_provider_data(provider_data)
        end.to change(VitaProvider, :count).by 1
        expect(scrape.created_count).to eq 1
      end
    end

    context "with a provider that matches the data" do
      let!(:provider) do
        create(
          :vita_provider,
          irs_id: "100",
          name: "Tax Help Palace",
          languages: "Spanish,English",
          appointment_info: "Required",
          last_scrape: prior_scrape
        )
      end

      it "marks the provider as scraped" do
        scrape.handle_irs_provider_data(provider_data)

        expect(provider.reload.last_scrape).to eq scrape
      end
    end

    context "with a provider that matches irs_id but had different properties" do
      let!(:provider) do
        create(
          :vita_provider,
          irs_id: "100",
          name: "Tax Help Castle",
          languages: "Spanish,English",
          appointment_info: "Required",
          last_scrape: prior_scrape
        )
      end

      it "updates the provider with new data, marks as scraped, and increments changed_count" do
        scrape.handle_irs_provider_data(provider_data)
        provider.reload
        expect(provider.name).to eq "Tax Help Palace"
        expect(provider.last_scrape).to eq scrape
        expect(scrape.changed_count).to eq 1
      end
    end

    context "with an archived provider that matches irs_id" do
      let!(:provider) do
        create(
          :vita_provider,
          irs_id: "100",
          name: "Tax Help Castle",
          languages: "Spanish,English",
          appointment_info: "Required",
          last_scrape: prior_scrape,
          archived: true
        )
      end

      it "updates the provider with new data, unarchives, marks as scraped, and increments changed_count" do
        scrape.handle_irs_provider_data(provider_data)
        provider.reload
        expect(provider.name).to eq "Tax Help Palace"
        expect(provider.last_scrape).to eq scrape
        expect(provider.archived).to eq false
        expect(scrape.changed_count).to eq 1
      end
    end
  end

  describe "#archive_all_unscraped_providers" do
    let!(:time_in_past) { Time.new(2020, 2, 1) }
    let!(:scrape) { create :provider_scrape }
    let!(:scraped_archived) { create :vita_provider, last_scrape: scrape, archived: true, updated_at: time_in_past }
    let!(:unscraped_archived) { create :vita_provider, last_scrape: nil, archived: true, updated_at: time_in_past }
    let!(:scraped_unarchived) { create :vita_provider, last_scrape: scrape, archived: false, updated_at: time_in_past }
    let!(:unscraped_unarchived) { create :vita_provider, last_scrape: nil, archived: false, updated_at: time_in_past }

    it "archives all unscraped, unarchived providers and no others" do
      scrape.archive_all_unscraped_providers
      scraped_archived.reload
      unscraped_archived.reload
      scraped_unarchived.reload
      unscraped_unarchived.reload

      expect(scraped_archived.updated_at).to eq time_in_past
      expect(unscraped_archived.updated_at).to eq time_in_past
      expect(unscraped_archived.last_scrape).to be_nil
      expect(scraped_unarchived.updated_at).to eq time_in_past

      expect(unscraped_unarchived.updated_at).not_to eq time_in_past
      expect(unscraped_unarchived.last_scrape).to eq scrape
      expect(unscraped_unarchived.archived).to eq true
    end

    it "sets archived count to the number of newly archived providers" do
      expect do
        scrape.archive_all_unscraped_providers
      end.to change(scrape, :archived_count).by 1
    end
  end
end
