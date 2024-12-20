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
    context "when nj and primary veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "yes", spouse_veteran: "no" }
      render_views
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text "You said you or your spouse are filing for the veteran exemption"
      end
    end

    context "when nj and spouse veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "no", spouse_veteran: "yes" }
      render_views
      it "shows veteran documentation requirements" do
        get :edit
        expect(response_html).to have_text "You said you or your spouse are filing for the veteran exemption"
      end
    end

    context "when nj and neither primary nor spouse are veteran" do
      let(:intake) { create :state_file_nj_intake, :married_filing_jointly, primary_veteran: "no", spouse_veteran: "no" }
      render_views
      it "does not show veteran documentation requirements" do
        get :edit
        expect(response_html).not_to have_text "You said you or your spouse are filing for the veteran exemption"
      end
    end
  end
end
