require "rails_helper"

RSpec.describe Questions::PhoneVerificationController, requires_default_vita_partners: true do
  let(:sms_phone_number) { "+15125551234" }
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (build :intake, sms_phone_number: sms_phone_number, visitor_id: visitor_id, locale: locale) }
  let(:intake) { client.intake }
  let(:locale) { "en" }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(MixpanelService).to receive(:send_event)
  end

  context 'before rendering edit' do
    context "if the sms phone number was blank" do
      let(:sms_phone_number) { nil }

      it "redirects back to the SMS phone number entry screen " do
        expect(
          get :edit, params: {}
        ).to redirect_to(Questions::CellPhoneNumberController.to_path_helper)
      end
    end

    it "enqueues a job to send a verification code" do
      expect {
        get :edit, params: {}
      }.to have_enqueued_job(RequestVerificationCodeTextMessageJob)
             .with(hash_including(
                     phone_number: "+15125551234",
                     locale: :en,
                     visitor_id: visitor_id,
                     service_type: :gyr,
                     client_id: client.id
                   ))
    end

    context "rate limiting" do
      context "when the same phone number is sent too many codes" do
        before { 5.times { get :edit, params: {} } }

        it "renders the page with an error and does not send another code" do
          expect {
            get :edit, params: {}
          }.not_to have_enqueued_job(RequestVerificationCodeTextMessageJob)

          expect(response).to have_http_status(:too_many_requests)
          expect(response).to render_template :edit
          expect(assigns(:form).errors[:verification_code]).to include I18n.t("views.questions.verification.too_many_requests")
        end

        it "still sends codes to other intakes" do
          intake.sms_phone_number = "+15125559999"
          expect {
            get :edit, params: {}
          }.to have_enqueued_job(RequestVerificationCodeTextMessageJob)
        end

        it "does not count reloads for the limited number against the IP limit" do
          20.times { get :edit, params: {} }

          intake.sms_phone_number = "+15125559999"
          expect {
            get :edit, params: {}
          }.to have_enqueued_job(RequestVerificationCodeTextMessageJob)
        end

        it "allows requests again after the hour passes" do
          travel 61.minutes do
            expect {
              get :edit, params: {}
            }.to have_enqueued_job(RequestVerificationCodeTextMessageJob)
          end
        end
      end

      context "when one IP address requests too many codes" do
        before do
          10.times do |i|
            intake.sms_phone_number = "+1512555#{i.to_s.rjust(4, "0")}"
            get :edit, params: {}
          end
        end

        it "blocks further requests from that IP" do
          intake.sms_phone_number = "+15125559999"
          expect {
            get :edit, params: {}
          }.not_to have_enqueued_job(RequestVerificationCodeTextMessageJob)
          expect(response).to have_http_status(:too_many_requests)
        end
      end
    end
  end
end