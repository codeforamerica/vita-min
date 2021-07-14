require "rails_helper"

describe Ctc::Questions::PhoneVerificationController do
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (create :ctc_intake, sms_phone_number: "+15125551234", visitor_id: visitor_id) }
  let(:intake) { client.intake }

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
end