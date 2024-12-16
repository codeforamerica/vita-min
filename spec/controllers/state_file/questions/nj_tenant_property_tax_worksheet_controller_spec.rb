require "rails_helper"

RSpec.describe StateFile::Questions::NjTenantPropertyTaxWorksheetController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#next_path" do
    it "next path is next_controller for property tax flow" do
      expect(subject.next_path).to eq(StateFile::NjPropertyTaxFlowHelper.next_controller({}))
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