require "rails_helper"

describe Questions::EmailVerificationController do
  let(:email_address) { "email@example.com" }

  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (build :intake, email_address: email_address, visitor_id: visitor_id, locale: locale) }
  let(:intake) { client.intake }
  let(:locale) { "en" }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(MixpanelService).to receive(:send_event)
  end

  context 'before rendering edit' do
    context "if the email was blank" do
      let(:email_address) { nil }

      it "redirects back to the email entry screen " do
        expect(
          get :edit, params: {}
        ).to redirect_to(Questions::EmailAddressController.to_path_helper)
      end
    end

    it "enqueues a job to send a verification code" do
      expect {
        get :edit, params: {}
      }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(hash_including(
                                                                     email_address: email_address,
                                                                     locale: :en,
                                                                     visitor_id: visitor_id,
                                                                     service_type: :gyr,
                                                                     client_id: client.id
                                                                   ))
    end

    context "rate limiting" do
      context "when the same address is sent too many codes" do
        before { 5.times { get :edit, params: {} } }

        it "renders the page with an error and does not send another code" do
          expect {
            get :edit, params: {}
          }.not_to have_enqueued_job(RequestVerificationCodeEmailJob)

          expect(response).to have_http_status(:too_many_requests)
          expect(response).to render_template :edit
          expect(assigns(:form).errors[:verification_code]).to include I18n.t("views.questions.verification.too_many_requests")
        end

        it "still sends codes to other intakes" do
          intake.email_address = "other@example.com"
          expect {
            get :edit, params: {}
          }.to have_enqueued_job(RequestVerificationCodeEmailJob)
        end

        it "does not count reloads for the limited address against the IP limit" do
          20.times { get :edit, params: {} }

          intake.email_address = "other@example.com"
          expect {
            get :edit, params: {}
          }.to have_enqueued_job(RequestVerificationCodeEmailJob)
        end

        it "allows requests again after the hour passes" do
          travel 61.minutes do
            expect {
              get :edit, params: {}
            }.to have_enqueued_job(RequestVerificationCodeEmailJob)
          end
        end
      end

      context "when one IP address requests too many codes" do
        before do
          10.times do |i|
            intake.email_address = "client#{i}@example.com"
            get :edit, params: {}
          end
        end

        it "blocks further requests from that IP" do
          intake.email_address = "other@example.com"
          expect {
            get :edit, params: {}
          }.not_to have_enqueued_job(RequestVerificationCodeEmailJob)
          expect(response).to have_http_status(:too_many_requests)
        end
      end
    end
  end
end
