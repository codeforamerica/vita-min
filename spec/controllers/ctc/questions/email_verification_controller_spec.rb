require "rails_helper"

describe Ctc::Questions::EmailVerificationController do
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (create :ctc_intake, email_address: "email@example.com", visitor_id: visitor_id, locale: locale) }
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
      }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(hash_including(
                                                                     email_address: "email@example.com",
                                                                     locale: :en,
                                                                     visitor_id: visitor_id,
                                                                     service_type: :ctc,
                                                                     client_id: client.id
                                                                   ))
    end
  end

  describe "#after_update_success" do
    let(:locale) { "en" }
    let(:current_user) { create :user }

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
    end

    context "they successfully verify their email" do
      it "sends a getting started message email" do
        subject.after_update_success

        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: client,
          message: instance_of(AutomatedMessage::CtcGettingStarted),
          locale: 'en'
        )
      end
    end
  end
end