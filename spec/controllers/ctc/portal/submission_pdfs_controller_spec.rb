require "rails_helper"

describe Ctc::Portal::SubmissionPdfsController do
  describe "#show" do
    let(:params) {{ id: 1 }}
    let(:client) { create :client_with_ctc_intake_and_return }
    let(:back) { "http://www.test.example.com/en" }
    let(:transient_url) { "https://somethingaws.something.something.com/123465198234"}

    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :show

    before do
      request.env["HTTP_REFERER"] = back
      allow(subject).to receive(:transient_storage_url).and_return(transient_url)
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

      context "when the client has a submission" do
        let!(:efile_submission) do
          client.tax_returns.last.efile_submissions.create
        end

        context "when the pdf document already exists" do
          let!(:existing_document) { create(:document, document_type: DocumentTypes::Form1040.key, tax_return: client.tax_returns.last, client: client) }

          before do
            allow(CreateSubmissionPdfJob).to receive(:perform_now)
          end

          it "uses the existing document without generating another one" do
            get :show, params: { id: efile_submission.id }

            expect(CreateSubmissionPdfJob).not_to have_received(:perform_now)
            expect(subject).to have_received(:transient_storage_url).with(existing_document.upload.blob)
            expect(response).to redirect_to transient_url
          end
        end

        context "when the pdf document does not already exist" do
          let(:document) { create :document }
          before do
            allow(CreateSubmissionPdfJob).to receive(:perform_now).and_return document
          end

          context "when it can be generated" do
            it "generates the document and redirects to the document path" do
              get :show, params: { id: efile_submission.id }

              expect(CreateSubmissionPdfJob).to have_received(:perform_now).with(efile_submission.id)
              expect(subject).to have_received(:transient_storage_url).with(document.upload.blob)
              expect(response).to redirect_to transient_url
            end
          end

          context "when an error was raised while generating the document" do
            before do
              allow(CreateSubmissionPdfJob).to receive(:perform_now).and_raise StandardError
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
end