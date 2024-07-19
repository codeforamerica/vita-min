require "rails_helper"

describe Ctc::Portal::VerificationAttemptsController do
  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :edit
    context "with an authenticated client" do
      let(:client) { create :ctc_client, intake: (build :ctc_intake) }
      before do
        sign_in client
      end

      context "when the client already has a verification attempt that has been submitted for review" do
        before do
          create :verification_attempt, :pending, client: client
        end

        it "redirects the client back to portal home" do
          get :edit
          expect(response).to redirect_to ctc_portal_root_path
        end
      end

      context "when the clients identity verification attempt has been denied" do
        before do
          client.touch(:identity_verification_denied_at)
        end

        it "redirects the client back to portal home" do
          get :edit
          expect(response).to redirect_to ctc_portal_root_path
        end
      end

      context "when the client identity verification attempt has been approved" do
        before do
          client.touch(:identity_verified_at)
        end

        it "redirects the client back to portal home" do
          get :edit
          expect(response).to redirect_to ctc_portal_root_path
        end
      end

      context "when there is already a verification attempt in the new state (files uploaded but not submitted" do
        let!(:verification_attempt) { create :verification_attempt, :new, client: client }

        it "loads the existing verification attempt to act upon" do
          get :edit
          expect(assigns(:verification_attempt)).to eq verification_attempt
        end
      end

      context "when there is not a new verification attempt for the client" do
        it "instantiates a new verification attempt" do
          get :edit
          expect(assigns(:verification_attempt)).to be_a_new(VerificationAttempt)
        end
      end
    end
  end

  describe "#update" do
    let(:client) { create :ctc_client, intake: (build :ctc_intake) }
    context "with an authenticated client" do
      before do
        sign_in client
      end

      context "when submitting the form" do
        let(:params) do
          {
              commit: "Continue"
          }
        end

        context "when both images exist" do
          let!(:verification_attempt) { create :verification_attempt, client: client }
          it "transitions the verification attempt to pending then redirects to portal home" do
            expect(verification_attempt.current_state).to eq "new"
            patch :update, params: params
            expect(response).to redirect_to ctc_portal_root_path
            expect(verification_attempt.reload.current_state).to eq "pending"
          end
        end

        context "when both of the images do not exist" do
          let!(:verification_attempt) { create :verification_attempt, client: client }
          before do
            verification_attempt.update(selfie: nil)
          end

          it "redirects back to edit" do
            patch :update, params: params
            expect(response).to redirect_to ctc_portal_verification_attempt_path
          end
        end

        context "when submitted with selfie image params" do
          let!(:verification_attempt) { create :verification_attempt, :new, client: client, selfie: nil }
          let(:params) do
            {
                verification_attempt: {
                    selfie: fixture_file_upload("test-pattern.png", "image/png")
                }
            }
          end

          it "updates the verification attempt with the image from params and redirects back to edit" do
            expect(verification_attempt.selfie.filename).to eq "test.jpg"
            patch :update, params: params
            verification_attempt.reload
            expect(verification_attempt.selfie.filename).to eq "test-pattern.png"
            expect(response).to redirect_to ctc_portal_verification_attempt_path
          end

          context "when submitted with an invalid file type" do
            render_views

            let(:params) do
              {
                verification_attempt: {
                  selfie: fixture_file_upload("test-pattern.html", "text/html")
                }
              }
            end

            it "does not update the verification attempt and renders a validation error" do
              expect {
                patch :update, params: params
              }.not_to change { verification_attempt.reload.selfie.filename.to_s }

              expect(response).to render_template :edit
              expect(response.body).to include "Please upload a valid document type."
            end
          end
        end

        context "when submitted with photo_identification image params" do
          let!(:verification_attempt) { create :verification_attempt, :new, client: client, selfie: nil }
          let(:params) do
            {
                verification_attempt: {
                    photo_identification: fixture_file_upload("test-pattern.png", "image/png")
                }
            }
          end

          it "updates the verification attempt with the image from params and redirects back to edit" do
            expect(verification_attempt.photo_identification.filename).to eq "test.jpg"
            patch :update, params: params
            verification_attempt.reload
            expect(verification_attempt.photo_identification.filename).to eq "test-pattern.png"
            expect(response).to redirect_to ctc_portal_verification_attempt_path
          end
        end
      end
    end
  end

  describe "#destroy" do
    context "with an authenticated user" do
      let(:client) { create :ctc_client, intake: (build :ctc_intake) }
      before do
        sign_in client
      end

      context "when the verification attempt does not belong to the authenticated client" do
        let(:verification_attempt) { create :verification_attempt }
        it "redirects the client away with a flash message" do
          delete :destroy, params: { id: verification_attempt.id, photo_type: "selfie" }
          expect(response).to redirect_to ctc_portal_verification_attempt_path
          expect(flash[:alert]).to eq "You are not authorized to take this action."
        end
      end

      context "when the photo_type param is not selfie or photo_identification" do
        let(:verification_attempt) { create :verification_attempt, client: client }
        it "redirects the client away with a flash message" do
          delete :destroy, params: { id: verification_attempt.id, photo_type: "cat_pic" }
          expect(response).to redirect_to ctc_portal_verification_attempt_path
          expect(flash[:alert]).to eq "You are not authorized to take this action."
        end
      end

      context "when the photo_type param is valid and the verification attempt belongs to the client" do
        let!(:verification_attempt) { create :verification_attempt, client: client }
        let(:params) do
          {
              id: verification_attempt.id,
              photo_type: "selfie"
          }
        end
        let(:active_storage_double) { double }
        before do
          allow_any_instance_of(VerificationAttempt).to receive(:selfie).and_return active_storage_double
          allow(active_storage_double).to receive(:purge_later)
        end

        it "will purge the associated record" do
          delete :destroy, params: params
          expect(assigns(:verification_attempt)).to have_received(:selfie)
          expect(active_storage_double).to have_received(:purge_later)
          expect(response).to redirect_to ctc_portal_verification_attempt_path
        end
      end
    end
  end

  describe "#paper-file" do
    let(:client) { create :client_with_ctc_intake_and_return }
    before do
      client.tax_returns.last.efile_submissions.create
    end

    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :paper_file

    context "with an authenticated client" do
      before do
        sign_in client
      end

      it "assigns submission to latest efile submission" do
        get :paper_file
        expect(assigns(:submission)).to eq client.efile_submissions.last
      end

      it "renders the template" do
        get :paper_file
        expect(response).to render_template "paper_file"
      end
    end
  end
end
