require "rails_helper"

describe StateFile::Questions::TermsAndConditionsController do
  StateFile::StateInformationService.active_state_codes.excluding("ny").each do |state_code|
    it_behaves_like :df_data_required, false, state_code
  end

  let(:intake) { create :state_file_az_refund_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views

    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "Easy Tax Filing"
    end
  end
end
