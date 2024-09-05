require "rails_helper"

RSpec.describe StateFile::NjCountyForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "all fields are required" do
        let(:invalid_params) do
          {
            :county => nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:county]).to include "Can't be blank."
        end
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, county: "Atlantic", municipality_code: "0101", municipality_name: "Absecon City" }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving a new county" do
      let(:valid_params) do
        { county: "Bergen" }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save

        expect(intake.county).to eq "Bergen"
      end

      it "resets municipality name and code" do
        form.save
        expect(intake.municipality_name).to eq nil
        expect(intake.municipality_code).to eq nil
      end
    end


    context "when saving the same county" do
      let(:valid_params) do
        { county: "Atlantic" }
      end

      it "does not reset municipality name and code" do
        form.save
        expect(intake.municipality_name).to eq "Absecon City"
        expect(intake.municipality_code).to eq "0101"
      end
    end
  end
end
