require "rails_helper"

RSpec.describe ZipCodes do
  describe ".coordinates_for_zip_code" do
    context "with an existing zip_code" do
      it "returns a latitude, longitude array" do
        expect(ZipCodes.coordinates_for_zip_code("99692")).to eq [53.8898, -166.5422]
      end
    end

    context "with a non-existent zip code" do
      it "returns nil" do
        expect(ZipCodes.coordinates_for_zip_code("1982379128738")).to eq nil
      end
    end
  end
end