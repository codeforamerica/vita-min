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
      get :edit
      expect(response).to be_successful
      expect(response_html).to have_text "state tax return is now submitted"
    end
  end

  describe "nj veteran content" do
    render_views
    let(:body_substring) { I18n.t('state_file.questions.submission_confirmation.nj_additional_content.body_html')[0..30] }
    # Searching for html as text in the document throws an error

    context "when nj and primary veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "yes", spouse_veteran: "no" }
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text body_substring
      end
    end

    context "when nj and spouse veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "no", spouse_veteran: "yes" }
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text body_substring
      end
    end

    context "when nj and neither primary nor spouse are veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "no", spouse_veteran: "no" }
      it "does not show veteran documentation requirements" do
        get :edit
        expect(response_html).not_to have_text body_substring
      end
    end
  end
end
