require "rails_helper"

RSpec.describe StateFile::NjCountyMunicipalityForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "without a county" do
        let(:invalid_params) do
          { county: nil }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:county]).to include "Can't be blank."
        end
      end
    end

    context "without a municipality code" do
      let(:invalid_params) do
        { municipality_code: nil }
      end

      it "is invalid" do
        expect(form.valid?).to eq false
        expect(form.errors[:municipality_code]).to include "Can't be blank."
      end
    end
  end

  describe ".save" do
    let(:intake) { create :state_file_nj_intake }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving a county and municipality code" do
      let(:valid_params) do
        { county: "Atlantic", municipality_code: "0101" }
      end

      it "saves county, code, and associated name" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.county).to eq "Atlantic"
        expect(intake.municipality_code).to eq "0101"
        expect(intake.municipality_name).to eq "Absecon City"
      end
    end
  end
end
