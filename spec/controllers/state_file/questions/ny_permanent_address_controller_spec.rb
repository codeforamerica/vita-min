require "rails_helper"

describe StateFile::Questions::NyPermanentAddressController do

  let(:intake) { create :state_file_ny_refund_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit, params: { us_state: "ny" }
      expect(response).to be_successful
      expect(response_html).to have_text "Did you live at this address"
    end
  end
end
