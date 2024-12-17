require "rails_helper"

RSpec.describe StateFile::Questions::NjHomeownerPropertyTaxController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#show?" do
    context "when indicated that they own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when indicated that they rent" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when indicated neither rent nor own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "neither" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when indicated both rent and own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when ineligible" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own", homeowner_home_subject_to_property_taxes: "no" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when worksheet required" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own", homeowner_more_than_one_main_home_in_nj: "yes" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when advance state" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own", homeowner_home_subject_to_property_taxes: "yes" }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when not eligible for property tax deduction or credit due to income" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "does not show" do
        allow(Efile::Nj::NjPropertyTaxEligibility).to receive(:determine_eligibility).with(intake).and_return(Efile::Nj::NjPropertyTaxEligibility::INELIGIBLE)
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when not eligible for property tax deduction but could be for credit" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "does not show" do
        allow(Efile::Nj::NjPropertyTaxEligibility).to receive(:determine_eligibility).with(intake).and_return(Efile::Nj::NjPropertyTaxEligibility::POSSIBLY_ELIGIBLE_FOR_CREDIT)
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when potentially eligible for property tax deduction or credit" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "shows" do
        allow(Efile::Nj::NjPropertyTaxEligibility).to receive(:determine_eligibility).with(intake).and_return(Efile::Nj::NjPropertyTaxEligibility::POSSIBLY_ELIGIBLE_FOR_DEDUCTION_OR_CREDIT)
        expect(described_class.show?(intake)).to eq true
      end
    end
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end
end