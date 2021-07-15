require "rails_helper"

describe Ctc::Questions::EmailVerificationController do
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (create :ctc_intake, email_address: "email@example.com", visitor_id: visitor_id) }
  let(:intake) { client.intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(MixpanelService).to receive(:send_event)
  end

  context 'before rendering edit' do
    it "enqueues a job to send a verification code" do
      expect {
        get :edit, params: { }
      }.to have_enqueued_job(RequestVerificationCodeEmailJob).with(hash_including(
                                                                     email_address: "email@example.com",
                                                                     locale: :en,
                                                                     visitor_id: visitor_id,
                                                                     service_type: :ctc,
                                                                     client_id: client.id
                                                                   ))
    end
  end
end