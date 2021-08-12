require "rails_helper"

describe Ctc::Questions::ConfirmLegalController do
  let(:intake) { create :ctc_intake, client: client }
  let(:client) { create :client, tax_returns: [create(:tax_return, year: 2020)] }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}

      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::ConfirmLegalForm
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:ip_address) { "1.1.1.1" }
    before do
      request.remote_ip = ip_address
      allow(MixpanelService).to receive(:send_event)
    end
    let(:params) do
      {
        ctc_confirm_legal_form: {
          consented_to_legal: "yes",
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "+240",
          client_system_time: "2021-07-28T21:21:32.306Z",
        }
      }
    end

    context "when submitting the form" do
      context "when checking 'I agree'" do
        it "create a submission with the status of 'preparing' and send client a message and redirect to portal home" do
          post :update, params: params

          expect(response).to redirect_to ctc_portal_root_path
          efile_submission = client.reload.tax_returns.last.efile_submissions.last
          expect(efile_submission.current_state).to eq "preparing"
          expect(efile_submission.efile_security_information.ip_address).to eq ip_address
        end

        it "sends a Mixpanel event" do
          post :update, params: params

          expect(MixpanelService).to have_received(:send_event).with hash_including(
            distinct_id: intake.visitor_id,
            event_name: "ctc_submitted_intake",
          )
        end

        context "when HOLD_OFF_NEW_EFILE_SUBMISSIONS is set" do
          around do |example|
            ENV['HOLD_OFF_NEW_EFILE_SUBMISSIONS'] = '1'
            example.run
            ENV.delete('HOLD_OFF_NEW_EFILE_SUBMISSIONS')
          end

          it "create a submission that is still in status 'new'" do
            post :update, params: params

            expect(response).to redirect_to ctc_portal_root_path
            efile_submission = client.reload.tax_returns.last.efile_submissions.last
            expect(efile_submission.current_state).to eq "new"
          end
        end
      end

      context "when not checking 'I agree'" do
        before do
          params[:ctc_confirm_legal_form][:consented_to_legal] = "no"
        end

        it "render edit with errors" do
          post :update, params: params
          expect(response).to render_template :edit
          expect(assigns(:form).errors).not_to be_blank
          expect(intake.consented_to_legal).to eq "unfilled"
        end
      end

      context "with invalid params" do
        context "efile security information fields are missing" do
          let(:params) do
            {
              ctc_confirm_legal_form: {
                consented_to_legal: "yes",
              }
            }
          end

          it "does not create the EfileSubmission, shows a flash message" do
            expect {
              post :update, params: params
            }.not_to change(EfileSubmission, :count)

            expect(flash[:alert]).to eq I18n.t("general.enable_javascript")
          end
        end
      end
    end
  end
end
