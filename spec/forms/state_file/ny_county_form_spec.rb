require "rails_helper"

RSpec.describe StateFile::NyCountyForm do
  let(:intake) { create :state_file_ny_intake,
                        residence_county: nil,
                        school_district: nil,
                        school_district_number: nil
  }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "all fields are required" do
        let(:invalid_params) do
          {
            :residence_county => nil,
            :school_district => nil,
            :school_district_number => nil
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:residence_county]).to include "Can't be blank."
          expect(form.errors[:school_district]).to include "Can't be blank."
          expect(form.errors[:school_district_number]).to include "Can't be blank."
        end
      end
    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }
    let(:valid_params) do
      {
        residence_county: "Albany",
        school_district: "Cool School District",
        school_district_number: 10,
      }
    end

    it "saves attributes" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.residence_county).to eq "Albany"
      expect(intake.school_district).to eq "Cool School District"
      expect(intake.school_district_number).to eq 10
    end
  end
end
