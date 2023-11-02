require "rails_helper"

RSpec.describe StateFile::NySchoolDistrictForm do
  let(:intake) { create :state_file_ny_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "name and code are required" do
        let(:invalid_params) do
          {
            school_district: nil,
            school_district_number: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

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
        school_district: "Carle Place",
        school_district_number: 88
      }
    end

    it "saves attributes" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.school_district).to eq "Carle Place"
      expect(intake.school_district_number).to eq 88
    end
  end
end
