require 'rails_helper'

RSpec.describe ZendeskInboundSmsJob, type: :job do
  let(:sms_ticket_id) { 1492 }
  let(:phone_number) { "14158161286" }
  let(:message_body) { "message_body here" }
  let(:fake_zendesk_sms_service) { double(ZendeskSmsService) }

  before do
    allow(ZendeskSmsService).to receive(:new).and_return(fake_zendesk_sms_service)
    allow(fake_zendesk_sms_service).to receive(:handle_inbound_sms).and_return(true)
  end

  describe "#perform" do
    before do
      described_class.perform_now(
        sms_ticket_id: sms_ticket_id,
        phone_number: phone_number,
        message_body: message_body,
      )
    end

    it "calls the service" do
      expect(fake_zendesk_sms_service).to have_received(:handle_inbound_sms).with(
        sms_ticket_id: sms_ticket_id,
        phone_number: phone_number,
        message_body: message_body,
      )
    end
  end
end

