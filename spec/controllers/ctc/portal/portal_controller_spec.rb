require "rails_helper"

describe Ctc::Portal::PortalController do
  let(:intake) { create :ctc_intake, current_step: "/en/last/question" }
  let(:client) { create :client, intake: intake, tax_returns: [create(:tax_return, year: 2021)] }

  context '#home' do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :home

    context "when authenticated" do
      before do
        sign_in client, scope: :client
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
          client.tax_returns.first.update(efile_submissions: [ create(:efile_submission, :rejected)])
        end

        it "renders with the submission status and nil current step" do
          get :home
          expect(assigns(:status)).to eq "rejected"
          expect(assigns(:current_step)).to eq nil
        end
      end
    end
  end

  context "#resubmit" do
    it_behaves_like :a_get_action_for_authenticated_clients_only, action: :home

    context "when authenticated" do
      let(:submission) { create(:efile_submission, :rejected, tax_return: client.tax_returns.first) }
      let(:params) do
        { ctc_resubmit_form:
          { "device_id"=>"2ED97833F3E12B652F96140884F867927DA6E12F",
            "user_agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
            "browser_language"=>"en-US",
            "platform"=>"MacIntel",
            "client_system_time"=>"Tue Aug 31 2021 11:46:22 GMT-0500 (Central Daylight Time)",
            "timezone_offset"=>"+300",
            "timezone" => "America/Chicago"
          }
        }
      end
      before do
        sign_in client, scope: :client
        allow(controller).to receive(:verify_recaptcha).and_return(true)
        allow(controller).to receive(:recaptcha_reply).and_return({ 'score' => "0.9" })
        client.tax_returns.first.update(efile_submissions: [submission])
      end

      it "updates status, makes a note, and redirects to the portal home" do
        expect {
          put :resubmit, params: params
        }.to change(client.efile_security_informations, :count).by(1)
         .and change(client.efile_submissions, :count).by(1)

        client.reload
        expect(client.efile_security_informations.last.ip_address).to be_present
        expect(client.efile_security_informations.last.timezone).to eq "America/Chicago"

        expect(client.efile_security_informations.last.recaptcha_score).to eq 0.9

        expect(client.recaptcha_scores.last.score).to eq 0.9

        system_note = SystemNote::CtcPortalAction.last
        expect(system_note.client).to eq(client)
        expect(system_note.data).to match({
          'model' => submission.to_global_id.to_s,
          'action' => 'resubmitted'
        })
        expect(submission.last_transition_to(:resubmitted)).to be_present
        expect(submission.current_state).to eq("resubmitted") # transitions to resubmitted and then to bundling
        expect(response).to redirect_to Ctc::Portal::PortalController.to_path_helper(action: :home)
      end

      context "without efile security information due to JS being disabled" do
        before do
          params[:ctc_resubmit_form]["device_id"] = nil
        end

        it "flashes an alert and does not save" do
          expect {
            put :resubmit, params: params
          }.to change(client.efile_security_informations, :count).by 0
          expect(flash[:alert]).to eq(I18n.t("general.enable_javascript"))

          expect(submission.current_state).to eq("rejected")
          expect(response).to redirect_to Ctc::Portal::PortalController.to_path_helper(action: :edit_info)
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
  end
end
