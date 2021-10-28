require "rails_helper"

describe Ctc::Questions::EmailVerificationController do
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (create :ctc_intake, email_address: "email@example.com", visitor_id: visitor_id, locale: locale), tax_returns: [build(:tax_return, status: "intake_before_consent")] }
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

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      allow(MixpanelService).to receive(:send_event)
    end

    context "they successfully verify their email" do
      it "sends a getting started message email" do
        subject.after_update_success

        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: client,
          message: AutomatedMessage::CtcGettingStarted,
          locale: 'en'
        )
      end

      it "sends a mixpanel event" do
        subject.after_update_success

        expect(MixpanelService).to have_received(:send_event).with hash_including(
          distinct_id: visitor_id,
          event_name: "ctc_contact_verified",
        )
      end

      it "updates the tax return status" do
        expect do
          subject.after_update_success
        end.to change { client.tax_returns.last.reload.status }.to("intake_in_progress")
      end

      context "when status is already beyond intake in progress" do
        before do
          client.tax_returns.last.transition_to("file_accepted")
        end

        it "does not change the status back to intake in progress" do
          subject.after_update_success
          expect(client.tax_returns.last.reload.status).to eq "file_accepted"
        end
      end
    end
  end
end
