require 'rails_helper'

describe NySchoolDistricts do
  describe ".find_by_id" do
    context "with a matching id" do
      it "returns the school district object" do
        result = described_class.find_by_id(497)
        expect(result.county_name).to eq "Nassau"
        expect(result.district_name).to eq "Valley Stream CHS"
        expect(result.use_elementary_school_district).to eq "Valley Stream 30"
        expect(result.code).to eq 657
        expect(result.county_code).to eq "NASS"
      end
    end

    context "with a non existing id" do
      it "returns nil" do
        result = described_class.find_by_id(9999)
        expect(result).to be_nil
      end
    end
  end

  describe ".county_labels_for_select" do
    it "returns a list of county display options from the csv" do
      result = described_class.county_labels
      expect(result.length).to eq 63
      expect(result).to include(
                          "Manhattan (see New York)",
                          "New York (Manhattan)",
                          "Richmond (Staten Island)",
                          "Kings (Brooklyn)",
                          "Madison",
                          "St. Lawrence"
                        )
    end
  end

  describe ".district_select_options_for_county" do
    context "with a valid county name" do
      it "returns a list of combined district names with ids" do
        result = described_class.district_select_options_for_county("Nassau")
        expect(result.length).to eq 63
        expect(result).to include(
                            ["Bellmore-Merrick CHS Bellmore", 441],
                            ["Bellmore-Merrick CHS North Merrick", 444],
                            ["Sewanhaka CHS Floral Park - Bellrose", 490],
                            ["Valley Stream CHS Valley Stream 24", 496],
                            ["Glen Cove", 457],
        )
      end
    end

    context "with a missing county name" do
      it "raises an error" do
        expect {
          described_class.district_select_options_for_county("Imaginary County")
        }.to raise_error(KeyError)
      end
    end
  end
end