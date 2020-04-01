# == Schema Information
#
# Table name: vita_providers
#
#  id               :bigint           not null, primary key
#  appointment_info :string
#  archived         :boolean          default(FALSE), not null
#  coordinates      :geography        point, 4326
#  dates            :string
#  details          :string
#  hours            :string
#  languages        :string
#  name             :string
#  created_at       :datetime
#  updated_at       :datetime
#  irs_id           :string           not null
#  last_scrape_id   :bigint
#
# Indexes
#
#  index_vita_providers_on_irs_id          (irs_id) UNIQUE
#  index_vita_providers_on_last_scrape_id  (last_scrape_id)
#
# Foreign Keys
#
#  fk_rails_...  (last_scrape_id => provider_scrapes.id)
#

require 'rails_helper'

describe VitaProvider do
  let(:provider) { build :vita_provider }

  describe "validations" do
    it "requires certain fields" do
      expect(provider).to be_valid

      invalid_provider = VitaProvider.new()
      expect(invalid_provider).not_to be_valid
      expect(invalid_provider.errors).to include(:irs_id)
    end

    it "enforces uniqueness on certain fields" do
      create :vita_provider, irs_id: "23456"
      provider_with_same_irs_id = build :vita_provider, irs_id: "23456"

      expect(provider_with_same_irs_id).not_to be_valid
    end
  end

  describe "unscraped_by" do
    let(:other_scrape) { create :provider_scrape }
    let!(:scrape) { create :provider_scrape }
    let!(:unscraped) { create :vita_provider }
    let!(:scraped) { create :vita_provider, last_scrape: scrape }
    let!(:scraped_by_another) { create :vita_provider, last_scrape: other_scrape }

    it "returns records that do not have the given last_scrape" do
      results = VitaProvider.unscraped_by(scrape)

      expect(results).to include(unscraped)
      expect(results).to include(scraped_by_another)
      expect(results).not_to include(scraped)
    end
  end

  describe "#set_coordinates" do
    it "can save a longitude, latitude point to the coordinates" do
      provider.set_coordinates(lat: 37.7749, lon: -122.4194)

      expect(provider).to be_valid
      expect(provider.coordinates.lat).to eq 37.7749
      expect(provider.coordinates.lon).to eq -122.4194
    end
  end

  describe ".sort_by_distance_from_zipcode" do
    context "with no providers found" do
      it "returns an empty list" do
        results = VitaProvider.sort_by_distance_from_zipcode("94609")

        expect(results).to eq []
      end
    end

    context "with archived providers" do
      let!(:unarchived_providers) do
        create_list :vita_provider, 2, :with_coordinates, lat_lon: [37.834519, -122.263273]
      end
      let!(:archived_providers) do
        create_list :vita_provider, 2, :with_coordinates, lat_lon: [37.834519, -122.263273], archived: true
      end

      it "does not return any archived providers" do
        results = VitaProvider.sort_by_distance_from_zipcode("94609")

        expect(results.count).to eq(2)
        expect(results).to include(*unarchived_providers)
        expect(results).not_to include(*archived_providers)
      end
    end

    context "with providers near and far" do
      let!(:local_vita_provider) { create :vita_provider, :with_coordinates, lat_lon: [37.840284, -122.274668] }
      let!(:faraway_vita_provider) { create :vita_provider, :with_coordinates, lat_lon: [35.098589, -119.559891] }

      it "finds VITA providers within 50 miles of zip code and sorts them closest to furthest" do
        results = VitaProvider.sort_by_distance_from_zipcode("94609")

        expect(results).to include local_vita_provider
        expect(results).not_to include faraway_vita_provider
      end

      it "returns a distance attribute for each record" do
        results = VitaProvider.sort_by_distance_from_zipcode("94609")

        expect(results.first.cached_query_distance).to eq 1071.34291762
      end
    end

    context "pagination" do
      let!(:closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.834519, -122.263273] }
      let!(:next_closest_providers) { create_list :vita_provider, 5, :with_coordinates, lat_lon: [37.826387, -122.269738] }

      it "defaults to first page when no page number argument" do
        results = VitaProvider.sort_by_distance_from_zipcode("94609")

        expect(results.size).to eq 5
        closest_providers.each do |provider|
          expect(results).to include provider
        end
      end

      it "returns results offset by page" do
        results = VitaProvider.sort_by_distance_from_zipcode("94609", 2)

        expect(results.size).to eq 5
        next_closest_providers.each do |provider|
          expect(results).to include provider
        end
      end
    end
  end

  describe "#parse_details" do
    let(:provider) { build :vita_provider, details: details }

    context "with a lot of weird lines in details" do
      let(:details) do
        <<~DETAILS
          637 Todhunter Avenue
          #19
          Closed all State and Federal Holidays
          West Sacramento, CA 95605
          916-572-0560
          Volunteer Prepared Taxes
        DETAILS
      end

      it "parses each piece correctly" do
        result = provider.parse_details
        expect(result[:street_address]).to eq "637 Todhunter Avenue"
        expect(result[:unit]).to eq "#19"
        expect(result[:notes]).to eq ["Closed all State and Federal Holidays"]
        expect(result[:city_state_zip]).to eq "West Sacramento, CA 95605"
        expect(result[:phone_number]).to eq "916-572-0560"
        expect(result[:service_type]).to eq "Volunteer Prepared Taxes"
      end
    end

    context "with no notes or unit" do
      let(:details) do
        <<~DETAILS
          1234 Main Street
          Oakland, CA 94609
          555-123-4567
          Volunteer Prepared Taxes
        DETAILS
      end

      it "parses each piece correctly" do
        result = provider.parse_details
        expect(result[:street_address]).to eq "1234 Main Street"
        expect(result[:unit]).to be_nil
        expect(result[:notes]).to eq []
        expect(result[:city_state_zip]).to eq "Oakland, CA 94609"
        expect(result[:phone_number]).to eq "555-123-4567"
        expect(result[:service_type]).to eq "Volunteer Prepared Taxes"
      end
    end

    context "with two lines of miscellaneous notes" do
      let(:details) do
        <<~DETAILS
          3810 Crenshaw Blvd
          Virtual Delivery on Thursday Only
          Drop Off Services Offered
          Los Angeles, CA 90008
          Volunteer Prepared Taxes
        DETAILS
      end

      it "parses each piece correctly" do
        result = provider.parse_details
        expect(result[:street_address]).to eq "3810 Crenshaw Blvd"
        expect(result[:unit]).to be_nil
        expect(result[:notes]).to eq ["Virtual Delivery on Thursday Only", "Drop Off Services Offered"]
        expect(result[:city_state_zip]).to eq "Los Angeles, CA 90008"
        expect(result[:phone_number]).to be_nil
        expect(result[:service_type]).to eq "Volunteer Prepared Taxes"
      end
    end

    context "with a minimal amount of details" do
      let(:details) do
        <<~DETAILS
          314 27th Street NE
          Puyallup, WA 98372
          Volunteer Prepared Taxes
        DETAILS
      end

      it "parses each piece correctly" do
        result = provider.parse_details
        expect(result[:street_address]).to eq "314 27th Street NE"
        expect(result[:unit]).to be_nil
        expect(result[:city_state_zip]).to eq "Puyallup, WA 98372"
        expect(result[:phone_number]).to be_nil
        expect(result[:service_type]).to eq "Volunteer Prepared Taxes"
      end
    end

    context "with different unit types" do
      it "parses each piece correctly" do
        ["Unit 3", "Ste 4", "Building 7", "floor 4", "2nd floor", "P.O. Box 39", "TEB 226", "Bldg EFGH", "School of Business"].each do |unit|
          details = <<~DETAILS
            314 27th Street NE
            #{unit}
            Puyallup, WA 98372
            Volunteer Prepared Taxes
          DETAILS
          provider = build :vita_provider, details: details
          result = provider.parse_details
          expect(result[:street_address]).to eq "314 27th Street NE"
          expect(result[:unit]).to eq unit
          expect(result[:city_state_zip]).to eq "Puyallup, WA 98372"
          expect(result[:phone_number]).to be_nil
          expect(result[:service_type]).to eq "Volunteer Prepared Taxes"
        end
      end
    end
  end

  describe "#same_as_irs_result?" do
    let(:details) do
      <<~DETAILS
        314 27th Street NE
        Building 7
        Puyallup, WA 98372
        Volunteer Prepared Taxes
      DETAILS
    end

    let(:hours) do
      <<~HOURS.strip
        MON 10:00AM-5:00PM
        TUE 10:00AM-5:00PM
        WED 10:00AM-5:00PM
        THU 10:00AM-5:00PM
        FRI 12:00PM-4:00PM
      HOURS
    end

    let(:provider) do
      build(
        :vita_provider,
        irs_id: "111",
        name: "Provider",
        details: details,
        dates: "06 MAY 2019 - 15 NOV 2019",
        hours: hours,
        languages: "English,Spanish",
        appointment_info: "Required"
      )
    end

    context "when everything matches" do
      let(:scraped_data) do
        {
          irs_id: "111",
          name: "Provider",
          provider_details: details,
          dates: "06 MAY 2019 - 15 NOV 2019",
          hours: hours,
          languages: ["English","Spanish"],
          appointment_info: "Required"
        }
      end

      it "returns true" do
        expect(provider.same_as_irs_result?(scraped_data)).to eq true
      end
    end

    context "when one thing is different" do
      let(:scraped_data) do
        {
          irs_id: "111",
          name: "Provider",
          provider_details: details,
          dates: "06 MAY 2019 - 15 NOV 2019",
          hours: hours,
          languages: ["English","Spanish","Vietnamese"],
          appointment_info: "Required"
        }
      end

      it "returns false" do
        expect(provider.same_as_irs_result?(scraped_data)).to eq false
      end
    end
  end

  describe "#update_with_irs_data" do
    let(:provider) { build :vita_provider }
    let(:details) do
      <<~DETAILS.strip
      6500 Rookin
      Bldg C
      Houston, TX 77074
      713-957-4357
      Volunteer Prepared Taxes
      DETAILS
    end

    let(:hours) do
      <<~HOURS.strip
        MON 10:00AM-5:00PM
        TUE 10:00AM-5:00PM
        WED 10:00AM-5:00PM
        THU 10:00AM-5:00PM
        FRI 12:00PM-4:00PM
      HOURS
    end

    let(:provider_data) do
      {
        name: "BakerRipley Year Round Center",
        irs_id: "10202",
        provider_details: details,
        dates: "06 MAY 2019 - 15 NOV 2019",
        languages: ["Spanish", "English"],
        appointment_info: "Required",
        hours: hours,
        lat_long: ["29.710592", "-95.496816"],
      }
    end

    it "correctly saves the record with the new data" do
      provider.update_with_irs_data(provider_data)

      expect(provider.id).to be_present
      expect(provider.name).to eq "BakerRipley Year Round Center"
      expect(provider.irs_id).to eq "10202"
      expect(provider.details).to eq details
      expect(provider.dates).to eq "06 MAY 2019 - 15 NOV 2019"
      expect(provider.languages).to eq "Spanish,English"
      expect(provider.appointment_info).to eq "Required"
      expect(provider.hours).to eq hours
      expect(provider.coordinates.lat).to eq 29.710592
      expect(provider.coordinates.lon).to eq -95.496816
    end
  end
end
