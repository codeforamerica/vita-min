require "rails_helper"

RSpec.describe StateFile::NyCountyForm do
  let(:intake) { create :state_file_ny_intake
  }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "all fields are required" do
        let(:invalid_params) do
          {
            :residence_county => nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false

          expect(form.errors[:residence_county]).to include "Can't be blank."
        end
      end
    end
  end

  describe "#save" do
    let(:form) { described_class.new(intake, valid_params) }
    let(:valid_params) do
      {
        residence_county: "Albany",
      }
    end

    it "saves attributes" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.residence_county).to eq "Albany"
    end
  end

  describe "if a NYC county is selected" do
    let(:form) { described_class.new(intake, valid_params) }
    let(:valid_params) do
      {
        residence_county: "Bronx",
      }
    end

    it "saves attributes" do
      expect(form.valid?).to eq true
      form.save

      expect(intake.residence_county).to eq "Bronx"
      expect(intake.nyc_full_year_resident).to eq "yes"
    end
  end
end
