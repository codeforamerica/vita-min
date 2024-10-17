require "rails_helper"

RSpec.describe StateFile::Questions::NcReviewController do
  let(:intake) { create :state_file_nc_intake }

  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end
end