require "rails_helper"

describe StateFile::Questions::MdTaxesOwedController do

  let(:intake) { create :state_file_md_owed_intake }

  before do
    sign_in intake, scope: :state_file_md_intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "You owe"
    end
  end
end
