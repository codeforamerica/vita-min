require "rails_helper"

RSpec.describe StateFile::NjHomeownerEligibilityForm do
  let(:intake) { create :state_file_nj_intake }

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, household_rent_own: "own", property_tax_paid: 123
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when ineligible" do
      let(:valid_params) do
        { homeowner_home_subject_to_property_taxes: "no" }
      end

      it "resets property_tax_paid" do
        form.save
        expect(intake.property_tax_paid).to eq nil
      end
    end

    context "when unsupported" do
      let(:valid_params) do
        { homeowner_more_than_one_main_home_in_nj: "yes" }
      end

      it "resets property_tax_paid" do
        form.save
        expect(intake.property_tax_paid).to eq nil
      end
    end

    context "when supported and eligible" do
      let(:valid_params) do
        { homeowner_more_than_one_main_home_in_nj: "no" }
      end

      it "does not reset property_tax_paid" do
        form.save
        expect(intake.rent_paid).to eq nil
        expect(intake.property_tax_paid).to eq 123
      end
    end
  end
end
