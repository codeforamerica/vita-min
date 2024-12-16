require "rails_helper"

RSpec.describe StateFile::Questions::NjHomeownerPropertyTaxWorksheetController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#next_path" do
    context "when both rent and own" do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :df_data_many_w2s,
          household_rent_own: "both",
          )
      }
      it "next path is tenant eligibility page" do
        expect(subject.next_path).to eq(StateFile::Questions::NjTenantEligibilityController.to_path_helper)
      end
    end

    context "when not both rent and own" do
      let(:intake) {
        create(
          :state_file_nj_intake,
          :df_data_many_w2s,
          household_rent_own: "own",
          )
      }
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