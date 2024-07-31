require "rails_helper"

describe StateFile::Questions::TaxesOwedController do

  let(:intake) { create :state_file_az_owed_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "You owe"
      expect(response_html).to have_text "Bank name"
    end
  end
end
