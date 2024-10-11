require "rails_helper"

RSpec.describe StateFile::NjTenantEligibilityForm do
  let(:intake) { create :state_file_nj_intake }

  describe ".save" do
    let(:intake) {
      create :state_file_nj_intake, household_rent_own: "rent", rent_paid: 123
    }
    let(:form) { described_class.new(intake, valid_params) }

    context "when ineligible" do
      let(:valid_params) do
        { tenant_home_subject_to_property_taxes: "no" }
      end

      it "resets rent_paid" do
        form.save
        expect(intake.rent_paid).to eq nil
      end
    end

    context "when unsupported" do
      let(:valid_params) do
        { tenant_more_than_one_main_home_in_nj: "yes" }
      end

      it "resets rent_paid" do
        form.save
        expect(intake.rent_paid).to eq nil
      end
    end

    context "when supported and eligible" do
      let(:valid_params) do
        { tenant_home_subject_to_property_taxes: "yes" }
      end

      it "does not reset rent_paid" do
        form.save
        expect(intake.property_tax_paid).to eq nil
        expect(intake.rent_paid).to eq 123
      end
    end
  end
end
