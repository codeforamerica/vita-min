require "rails_helper"

RSpec.describe StateFile::Questions::NjIneligiblePropertyTaxController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#next_path" do
    context "when indicated both rent and own and has not yet answered tenant eligibility" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both" }
      it "next path is tenant eligibility" do
        expect(subject.next_path).to eq(StateFile::Questions::NjTenantEligibilityController.to_path_helper)
      end
    end

    context "when indicated both rent and own and has already answered tenant eligibility" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "both", tenant_home_subject_to_property_taxes: "no"  }
      it "next path is next_controller for property tax flow" do
        expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowHelper.next_controller({}))
      end
    end

    context "when not both rent and own" do
      let(:intake) { create :state_file_nj_intake, household_rent_own: "own" }
      it "next path is next_controller for property tax flow" do
        expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowHelper.next_controller({}))
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