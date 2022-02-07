require "rails_helper"

RSpec.describe Questions::PhoneVerificationController, requires_default_vita_partners: true do
  let(:visitor_id) { "asdfasdfa" }
  let(:client) { create :client, intake: (create :intake, sms_phone_number: "+15125551234", visitor_id: visitor_id, locale: locale) }
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
      }.to have_enqueued_job(RequestVerificationCodeTextMessageJob)
             .with(hash_including(
                     phone_number: "+15125551234",
                     locale: :en,
                     visitor_id: visitor_id,
                     service_type: :gyr,
                     client_id: client.id
                   ))
    end
  end
end