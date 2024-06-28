require "rails_helper"

describe StateFile::Questions::SubmissionConfirmationController do

  let(:intake) { create :state_file_az_refund_intake}
  let!(:submission) { create :efile_submission, :for_state, data_source: intake }
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit, params: { us_state: "az" }
      expect(response).to be_successful
      expect(response_html).to have_text "state tax return is now submitted"
    end
  end
end
