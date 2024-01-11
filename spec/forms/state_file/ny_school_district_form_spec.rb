require "rails_helper"

RSpec.describe StateFile::NySchoolDistrictForm do
  let(:intake) { create :state_file_ny_intake }

  describe ".from_intake" do
    context "with an existing school district" do
      let(:intake) { create :state_file_ny_intake, school_district_id: 492 }

      it "prepopulates the form with the school district id" do
        form = described_class.from_intake(intake)
        expect(form.school_district_id).to eq 492
      end
    end
  end

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "without a district id" do
        let(:invalid_params) do
          {
            school_district_id: nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:school_district_id]).to include "Can't be blank."
        end
      end
    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }
    let(:valid_params) do
      {
        school_district_id: 492
      }
    end

    it "saves attributes" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.school_district_id).to eq 492
      expect(intake.school_district).to eq "Sewanhaka CHS"
      expect(intake.school_district_number).to eq 424
    end
  end
end
