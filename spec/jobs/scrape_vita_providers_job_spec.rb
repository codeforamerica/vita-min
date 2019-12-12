require 'rails_helper'

describe ScrapeVitaProvidersJob do
  let(:scrape_vita_providers_service_spy) { instance_double(ScrapeVitaProvidersService) }

  before do
    allow(ScrapeVitaProvidersService).to receive(:new).and_return scrape_vita_providers_service_spy
  end

  describe '#perform' do
    let(:irs_id) { "54321" }
    let(:provider_data) do
      details = <<~DETAILS
        777 Stockton Street
        #104
        San Francisco, CA 94108
        415-421-2111
        Volunteer Prepared Taxes
      DETAILS

      [
        {
          name: "Chinese Newcomers Service Ctr",
          provider_details: details,
          irs_id: irs_id,
          lat_long: ["37.792618", "-122.407631"],
          dates: "26 JAN 2019 - 12 OCT 2019",
          hours: nil,
          languages: ["Chinese", "Cantonese", "Mandarin", "English", "Vietnamese"],
          appointment_info: "Required",
        }
      ]
    end

    before do
      allow(scrape_vita_providers_service_spy).to receive(:import).and_return provider_data
    end

    it 'calls the ScrapeVitaProvidersService' do
      ScrapeVitaProvidersJob.new.perform

      expect(scrape_vita_providers_service_spy).to have_received(:import)
    end

    context "new providers data" do
      it "creates new records for new irs_id's" do
        expect{
          ScrapeVitaProvidersJob.new.perform
        }.to change(VitaProvider, :count).by 1

        provider = VitaProvider.last
        expect(provider.name).to eq "Chinese Newcomers Service Ctr"
        expect(provider.coordinates.lon).to eq -122.407631
        expect(provider.coordinates.lat).to eq 37.792618
        expect(provider.languages).to eq "Chinese,Cantonese,Mandarin,English,Vietnamese"
      end
    end

    context "existing providers data" do
      it "updates records for existing irs_id's" do
        existing_provider = create :vita_provider, irs_id: irs_id, name: "Old Provider"

        expect{
          ScrapeVitaProvidersJob.new.perform
        }.not_to change(VitaProvider, :count)

        provider = VitaProvider.last
        expect(provider).to eq existing_provider
        expect(provider.name).to eq "Chinese Newcomers Service Ctr"
      end
    end
  end
end
