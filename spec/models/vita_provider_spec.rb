# == Schema Information
#
# Table name: vita_providers
#
#  id               :bigint           not null, primary key
#  appointment_info :string
#  coordinates      :geography({:srid point, 4326
#  dates            :string
#  details          :string
#  hours            :string
#  languages        :string
#  name             :string
#  irs_id           :string           not null
#
# Indexes
#
#  index_vita_providers_on_irs_id  (irs_id) UNIQUE
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
      provider = create :vita_provider, irs_id: "23456"
      provider_with_same_irs_id = build :vita_provider, irs_id: "23456"

      expect(provider_with_same_irs_id).not_to be_valid
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
end
