require "rails_helper"

describe Ctc::Questions::PhoneVerificationController do
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (create :ctc_intake, sms_phone_number: "+15125551234", visitor_id: visitor_id, locale: locale) }
  let(:intake) { client.intake }
  let(:locale) { "en" }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(MixpanelService).to receive(:send_event)
  end

  context 'before rendering edit' do
    it "enqueues a job to send a verification code" do
      expect {
        get :edit, params: {}
      }.to have_enqueued_job(RequestVerificationCodeTextMessageJob).with(hash_including(
                                                                       phone_number: "+15125551234",
                                                                       locale: :en,
                                                                       visitor_id: visitor_id,
                                                                       service_type: :ctc,
                                                                       client_id: client.id
                                                                   ))
    end
  end

  describe "#after_update_success" do
    let(:locale) { "es" }
    let(:current_user) { create :user }

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
    end

    context "they successfully verify their cell phone number" do
      it "sends a getting started message text" do
        subject.after_update_success

        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: client,
          message: instance_of(AutomatedMessage::CtcGettingStarted),
          locale: 'es'
        )
      end
    end
  end
end