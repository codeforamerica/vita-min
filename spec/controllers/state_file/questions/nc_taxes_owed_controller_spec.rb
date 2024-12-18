require "rails_helper"

describe StateFile::Questions::NcTaxesOwedController do

  let(:intake) { create :state_file_nc_intake, :taxes_owed }

  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "You owe"
      expect(response_html).to have_text "Routing Number"
    end
  end
end
