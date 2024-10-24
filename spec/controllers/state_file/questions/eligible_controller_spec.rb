require "rails_helper"

describe StateFile::Questions::EligibleController do

  let(:intake) { create :state_file_az_refund_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "You can use this tool to file your"
    end
  end
end
