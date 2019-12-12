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
end
