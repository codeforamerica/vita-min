require "rails_helper"

describe ScrapeVitaProvidersJob do
  let(:scrape_vita_providers_service_spy) { instance_double(ScrapeVitaProvidersService) }

  before do
    allow(ScrapeVitaProvidersService).to receive(:new).and_return scrape_vita_providers_service_spy
  end

  describe "#perform" do
    let!(:unchanged_provider) { create :vita_provider, irs_id: "1111", name: "No Changes", languages: "English" }
    let!(:changed_provider) { create :vita_provider, irs_id: "2222", name: "Before Change" }
    let!(:deprecated_provider) { create :vita_provider, irs_id: "3333", name: "Soon to be Archived" }
    let(:provider_data) do
      [
        {
          irs_id: "2222",
          name: "After Change",
          provider_details: nil,
          lat_long: ["37.792618", "-122.407631"],
          dates: nil,
          hours: nil,
          languages: [],
          appointment_info: nil,
        },
        {
          irs_id: "0000",
          name: "First New Site",
          provider_details: nil,
          lat_long: ["37.792618", "-122.407631"],
          dates: nil,
          hours: nil,
          languages: [],
          appointment_info: nil,
        },
        {
          irs_id: "1111",
          name: "No Changes",
          provider_details: nil,
          lat_long: ["37.792618", "-122.407631"],
          dates: nil,
          hours: nil,
          languages: ["English"],
          appointment_info: nil,
        },
      ]
    end

    before do
      allow(scrape_vita_providers_service_spy).to receive(:import).and_return provider_data
      allow(MixpanelService).to receive(:send_event)
    end

    it "creates, updates, and archives VitaProvider records to match the IRS website" do
      expect{
        ScrapeVitaProvidersJob.new.perform
      }.to change(VitaProvider, :count).by 1
      unchanged_provider.reload
      deprecated_provider.reload
      changed_provider.reload
      new_provider = VitaProvider.where(irs_id: "0000").first

      last_scrape = ProviderScrape.last
      expect(VitaProvider.count).to eq 4
      expect(last_scrape.changed_count).to eq 1
      expect(last_scrape.archived_count).to eq 1
      expect(last_scrape.created_count).to eq 1
      expect(new_provider).to be_present
      expect(new_provider.last_scrape).to eq last_scrape
      expect(unchanged_provider.last_scrape).to eq last_scrape
      expect(deprecated_provider.last_scrape).to eq last_scrape
      expect(changed_provider.last_scrape).to eq last_scrape
      expect(deprecated_provider.archived).to eq true
      expect(changed_provider.name).to eq "After Change"
    end

    it "outputs a report of the differences" do
      result = ScrapeVitaProvidersJob.new.perform

      expect(result).to eq <<~REPORT
        Finished updating all provider records!
        ---------------------------------------
        Total provider count before scraping: 3
        Total provider count after scraping: 4
        Listed provider count before scraping: 3
        Listed provider count after scraping: 3

        Newly created record count: 1
        Changed record count: 1
        Newly archived record count: 1
      REPORT
    end

    it "sends mixpanel event with stats" do
      ScrapeVitaProvidersJob.new.perform

      data = {
        total_provider_count_before: 3,
        total_provider_count_after: 4,
        listed_provider_count_before: 3,
        listed_provider_count_after: 3,
        new_provider_count: 1,
        changed_provider_count: 1,
        archived_provider_count: 1,
      }
      expect(MixpanelService).to have_received(:send_event).with(
        distinct_id: ScrapeVitaProvidersJob::MIXPANEL_ROBOT_ID,
        event_name: "scrape_vita_providers",
        data: data,
      )
    end

    context "with a recent partial scrape" do
      let(:current_time) { Time.new(2020, 4, 15) }
      let(:previous_update_time) { current_time - 1.hour }
      let!(:recent_scrape) { create :provider_scrape, created_at: previous_update_time }
      let!(:previously_scraped_provider) do
        create(
          :vita_provider,
          irs_id: "0009",
          name: "Already Been Scraped",
          last_scrape: recent_scrape,
          updated_at: previous_update_time
        )
      end

      before do
        allow(Time).to receive(:now).and_return(current_time)
        allow(previously_scraped_provider).to receive(:update)
      end

      it "uses the recent scrape and does not update previously scraped records" do
        ScrapeVitaProvidersJob.new.perform

        previously_scraped_provider.reload
        expect(previously_scraped_provider).not_to have_received(:update)
        expect(previously_scraped_provider.updated_at).to eq previous_update_time
        expect(previously_scraped_provider.last_scrape).to eq recent_scrape

        expect(unchanged_provider.reload.last_scrape).to eq recent_scrape
        expect(deprecated_provider.reload.last_scrape).to eq recent_scrape
        expect(changed_provider.reload.last_scrape).to eq recent_scrape
        new_provider = VitaProvider.where(irs_id: "0000").first
        expect(new_provider.last_scrape).to eq recent_scrape
      end
    end
  end
end
