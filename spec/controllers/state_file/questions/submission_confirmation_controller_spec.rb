require "rails_helper"

describe StateFile::Questions::SubmissionConfirmationController do
  let(:intake) { create :state_file_az_refund_intake}
  let!(:submission) { create :efile_submission, :for_state, data_source: intake }
  before do
    sign_in intake
    allow(subject).to receive(:current_intake).and_return(intake)
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
    let(:mfj_body_html) { I18n.t('state_file.questions.submission_confirmation.nj_additional_content.body_mfj_html')[0..30] }
    let(:body_html) { I18n.t('state_file.questions.submission_confirmation.nj_additional_content.body_html')[0..30] }
    render_views

    context "single veteran" do
      let(:intake) { create :state_file_nj_intake, primary_veteran: "yes", filing_status: :single }
      
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text body_html
      end
    end

    context "when nj and primary veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "yes", spouse_veteran: "no" }
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text mfj_body_html
      end
    end

    context "when nj and spouse veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "no", spouse_veteran: "yes" }
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text mfj_body_html
      end
    end

    context "when nj and neither primary nor spouse are veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "no", spouse_veteran: "no" }
      it "does not show veteran documentation requirements" do
        get :edit
        expect(response_html).not_to have_text body_html
        expect(response_html).not_to have_text mfj_body_html
      end
    end
  end
end
