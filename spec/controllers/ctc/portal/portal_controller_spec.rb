require "rails_helper"

describe Ctc::Portal::PortalController do
  let!(:intake) { build :ctc_intake, current_step: "/en/last/question" }
  let!(:client) { create :client, intake: intake, tax_returns: [build(:ctc_tax_return)] }

  context '#home' do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :home

    context "when authenticated" do
      before do
        sign_in client, scope: :client
      end

      context "when the client has a fraud held submission and has not yet been verified" do
        before do
          client.tax_returns.first.update(efile_submissions: [create(:efile_submission, :fraud_hold)])
          allow(client).to receive(:identity_verified_at).and_return nil
        end

        it "redirects to the verification flow" do
          get :home
          expect(response).to redirect_to ctc_portal_verification_attempt_path
        end
      end

      it "renders home layout" do
        get :home

        expect(response).to render_template "home"
      end

      context "when there is no efile_submission" do
        it "renders with intake_in_progress status and defined current_step" do
          get :home
          expect(assigns(:status)).to eq "intake_in_progress"
          expect(assigns(:current_step)).to eq "/en/last/question"
        end
      end

      context "when an efile submission exists" do
        before do
          client.tax_returns.first.update(efile_submissions: [create(:efile_submission, :rejected)])
        end

        it "renders with the submission status and nil current step" do
          get :home
          expect(assigns(:status)).to eq "rejected"
          expect(assigns(:current_step)).to eq nil
        end

        context "when there are multiple errors and at least one of them is auto-cancel" do
          let(:auto_cancel_error) { create(:efile_error, auto_cancel: true, service_type: :ctc, expose: true) }
          let(:auto_cancel_transition_error) { create(:efile_submission_transition_error, efile_error: auto_cancel_error) }
          before do
            client.tax_returns.first.efile_submissions.first.last_transition.update(efile_submission_transition_errors: [
              create(:efile_submission_transition_error, efile_error: create(:efile_error, auto_wait: true, service_type: :ctc, expose: true)),
              create(:efile_submission_transition_error, efile_error: create(:efile_error, auto_wait: true, service_type: :ctc, expose: true)),
              auto_cancel_transition_error
            ])
          end

          it "exposes one of the auto-cancel errors" do
            get :home
            expect(assigns(:exposed_error)).to eq auto_cancel_transition_error
          end
        end

        context "when there are multiple errors and none of them are auto-cancel" do
          let(:efile_submission_transition_error) { create(:efile_submission_transition_error, efile_error: create(:efile_error, auto_wait: true, expose: true)) }
          before do
            client.tax_returns.first.efile_submissions.first.last_transition.update(efile_submission_transition_errors: [
              efile_submission_transition_error,
              create(:efile_submission_transition_error, efile_error: create(:efile_error, auto_wait: true, expose: true)),
            ])
          end

          it "exposes one of the auto-cancel errors" do
            get :home
            expect(assigns(:exposed_error)).to eq efile_submission_transition_error
          end
        end
      end
    end
  end

  context "#edit_info" do
    context "when there are no efile_submissions for the client" do
      before do
        allow(Sentry).to receive(:capture_message)
        client.efile_submissions.destroy_all
        sign_in client, scope: :client
      end

      it "redirects to home" do
        expect(
          get :edit_info
        ).to redirect_to(ctc_portal_root_path)
        expect(Sentry).to have_received(:capture_message).with("Client #{client.id} unexpectedly lacks an efile submission.")
      end
    end

    context "when GetCTC is not open for edits" do
      before do
        sign_in client, scope: :client
        allow(subject).to receive(:open_for_ctc_read_write?).and_return(false)
      end

      it "redirects to home" do
        expect(
          get :edit_info
        ).to redirect_to(ctc_portal_root_path)
      end
    end
  end
end
