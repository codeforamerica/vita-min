require "rails_helper"

describe StateFile::Questions::TermsAndConditionsController do
  let(:intake) { create :state_file_az_refund_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    it_behaves_like :df_data_required, false, :az

    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "Easy Tax Filing"
    end
  end
end
