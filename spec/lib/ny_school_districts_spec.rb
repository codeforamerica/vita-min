require 'rails_helper'

describe NySchoolDistricts do
  describe ".combined_name" do
    let(:intake) {
      create :state_file_ny_intake,
             residence_county: "Nassau",
             school_district: school_district,
             school_district_number: school_district_number
    }

    context "intake doesn't have fields for name or number" do
      let(:school_district) { nil }
      let(:school_district_number) { nil }

      it "returns nil" do
        result = described_class.combined_name(intake)
        expect(result).to be_nil
      end
    end

    context "original name is different from combined name" do
      let(:school_district) { "Bellmore-Merrick CHS" }
      let(:school_district_number) { 441 }

      it "returns combined name" do
        result = described_class.combined_name(intake)
        expect(result).to eq "Bellmore-Merrick CHS North Bellmore"
      end
    end

    context "original name is the same as combined name" do
      let(:school_district) { "Bellmore" }
      let(:school_district_number) { 46 }

      it "returns the same name" do
        result = described_class.combined_name(intake)
        expect(result).to eq "Bellmore"
      end
    end
  end
end