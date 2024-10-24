require "rails_helper"

RSpec.describe StateFile::Questions::NjTenantRentPaidController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#show?" do
    context "when indicated that they rent" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent" }
      it "shows" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when indicated that they own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
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

    context "when ineligible hard no" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent", tenant_home_subject_to_property_taxes: "no" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when unsupported soft no" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent", tenant_more_than_one_main_home_in_nj: "yes" }
      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when advance state" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "rent", tenant_home_subject_to_property_taxes: "yes" }
      it "shows" do
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