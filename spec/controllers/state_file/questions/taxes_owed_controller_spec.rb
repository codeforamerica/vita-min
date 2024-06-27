require "rails_helper"

describe StateFile::Questions::TaxesOwedController do

  let(:intake) { create :state_file_az_owed_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit, params: { us_state: "az" }
      expect(response).to be_successful
    end
  end
end
