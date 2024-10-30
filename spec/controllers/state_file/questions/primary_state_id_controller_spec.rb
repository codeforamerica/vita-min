require "rails_helper"

describe StateFile::Questions::PrimaryStateIdController do

  let(:intake) { create :state_file_az_refund_intake}
  before do
    sign_in intake
  end

  describe '#edit' do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "your state-issued ID"
      expect(response_html).to have_text "ID Type"
    end
  end

  describe "for ID intake" do
    let(:intake) { create :state_file_id_intake }
    before do
      sign_in intake
    end

    render_views
    it 'has correct help text' do
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "Many state revenue agencies, including Idaho"
    end
  end
end
