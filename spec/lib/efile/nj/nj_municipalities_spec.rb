require 'rails_helper'

describe Efile::Nj::NjMunicipalities do
  describe ".find_name_by_county_and_code" do
    context "with a valid county / code pair" do
      it "returns municipality name" do
        result = described_class.find_name_by_county_and_code("Atlantic", "0102")
        expect(result).to eq "Atlantic City"
      end
    end

    context "with a valid county and invalid code for that county" do
      it "raises an error" do
        expect {
          described_class.find_name_by_county_and_code("Atlantic", "9999")
        }.to raise_error(KeyError)
      end
    end

    context "with an invalid county and invalid code" do
      it "raises an error" do
        expect {
          described_class.find_name_by_county_and_code("Imaginary County", "9999")
        }.to raise_error(KeyError)
      end
    end
  end

  describe ".county_options" do
    it "returns list of counties" do
      result = described_class.county_options
      expect(result.length).to eq 21
      expect(result).to include(
                            "Atlantic",
                            "Bergen",
                            "Burlington",
                            "Camden",
                            "Cape May",
                            "Cumberland",
                            "Essex",
                            "Gloucester",
                            "Hudson",
                            "Hunterdon",
                            "Mercer",
                            "Middlesex",
                            "Monmouth",
                            "Morris",
                            "Ocean",
                            "Passaic",
                            "Salem",
                            "Somerset",
                            "Sussex",
                            "Union",
                            "Warren"
                        )
    end
  end

  describe ".municipality_select_options_for_county" do
    context "with a valid county name" do
      it "returns a list of municipalities and associated codes" do
        result = described_class.municipality_select_options_for_county("Hudson")
        expect(result.length).to eq 12
        expect(result).to include(
                            ["Bayonne City", "0901"],
                            ["East Newark Borough", "0902"],
                            ["Guttenberg Town", "0903"],
                            ["Harrison Town", "0904"],
                            ["Hoboken City", "0905"],
                            ["Jersey City", "0906"],
                            ["Kearny Town", "0907"],
                            ["North Bergen Township", "0908"],
                            ["Secaucus Town", "0909"],
                            ["Union City", "0910"],
                            ["Weehawken Township", "0911"],
                            ["West New York Town", "0912"],
                          )
      end
    end

    context "with a missing county name" do
      it "raises an error" do
        expect {
          described_class.municipality_select_options_for_county("Imaginary County")
        }.to raise_error(KeyError)
      end
    end
  end
end