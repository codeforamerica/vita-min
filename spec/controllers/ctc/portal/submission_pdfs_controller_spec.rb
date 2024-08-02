require "rails_helper"

describe Ctc::Portal::SubmissionPdfsController do
  include PdfSpecHelper
  include CtcSubmissionHelper

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
        let(:efile_submission) { create :efile_submission, :ctc }

        it "redirects and sets a flash message" do
          get :show, params: { id: efile_submission.id }

          expect(response).to redirect_to back
          expect(flash[:alert]).to eq "We encountered a problem generating your tax return pdf. For assistance, please reach out to GetCTC client support."
        end
      end

      context "when the client has a submission" do
        let!(:efile_submission) do
          client.tax_returns.last.efile_submissions.create
        end
        before do
          create_qualifying_dependents(efile_submission)
        end

        context "when it can be generated" do
          let!(:bank_account) { create :bank_account, intake: client.intake }

          it "generates the document and redirects to the document path" do
            get :show, params: { id: efile_submission.id }

            tempfile = Tempfile.new('output.pdf')
            tempfile.write(response.body)

            expect(filled_in_values(tempfile.path)).to match(a_hash_including(
                                                            "RoutingTransitNum35b" => bank_account.routing_number,
                                                            "DepositorAccountNum35d" => bank_account.account_number,
                                                            "BankAccountTypeCd" => "Checking",
                                                            ))
          end

          context "when the upload is not yet attached" do
            let!(:document_without_attachment) { create :document, client: client, tax_return: efile_submission.tax_return, document_type: DocumentTypes::Form1040.key }
            before do
              document_without_attachment.upload.destroy
            end

            it "shows a flash message to wait and refresh" do
              get :show, params: { id: efile_submission.id }

              expect(response).to redirect_to back
              expect(flash[:alert]).to eq I18n.t("views.ctc.portal.submission_pdfs.not_ready")
            end
          end
        end

        context "when an error was raised while generating the document" do
          before do
            allow_any_instance_of(EfileSubmission).to receive(:generate_filing_pdf).and_raise StandardError
          end

          it "redirects and flashes a message" do
            get :show, params: { id: efile_submission.id }

            expect(response).to redirect_to back
            expect(flash[:alert]).to eq "We encountered a problem generating your tax return pdf. For assistance, please reach out to GetCTC client support."
          end
        end
      end
    end
  end
end