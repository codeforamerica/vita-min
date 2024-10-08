require "rails_helper"

RSpec.describe StateFile::NjHouseholdRentOwnForm do
  let(:intake) { create :state_file_nj_intake }

  describe "validations" do
    let(:form) { described_class.new(intake, invalid_params) }

    context "invalid params" do
      context "all fields are required" do
        let(:invalid_params) do
          {
            :household_rent_own => nil,
          }
        end

        it "is invalid" do
          expect(form.valid?).to eq false
          expect(form.errors[:household_rent_own]).to include "Can't be blank."
        end
      end
    end
  end

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, household_rent_own: "own", property_tax_paid: 123
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when saving a new selection" do
      let(:valid_params) do
        { household_rent_own: "rent" }
      end

      it "saves attributes" do
        expect(form.valid?).to eq true
        form.save
        expect(intake.household_rent_own).to eq "rent"
      end

      it "resets rent_paid and property_tax_paid" do
        form.save
        expect(intake.rent_paid).to eq nil
        expect(intake.property_tax_paid).to eq nil
      end
    end

    context "when saving the same selection" do
      let(:valid_params) do
        { household_rent_own: "own" }
      end

      it "does not reset rent_paid and property_tax_paid" do
        form.save
        expect(intake.rent_paid).to eq nil
        expect(intake.property_tax_paid).to eq 123
      end
    end
  end
end
