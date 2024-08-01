require "rails_helper"

describe Ctc::Portal::SubmissionPdfsController do
  include PdfSpecHelper

  describe "#show" do
    let(:params) {{ id: 1 }}
    let(:client) { create :client_with_ctc_intake_and_return }
    let!(:dependent) { create :qualifying_child, intake: client.intake }
    let(:back) { "http://test.host/en" }

    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :show

    before do
      client.intake.update(refund_payment_method: 'direct_deposit')
      request.env["HTTP_REFERER"] = back
    end

    context "with an authenticated client" do
      before do
        sign_in client
      end

      context "when the efile_submission id provided does not belong to the current client" do
        let(:efile_submission) { create :efile_submission }

        it "redirects and sets a flash message" do
          get :show, params: { id: efile_submission.id }

          expect(response).to redirect_to back
          expect(flash[:alert]).to eq "We encountered a problem generating your tax return pdf. For assistance, please reach out to GetCTC client support."
        end
      end
    end
  end
end