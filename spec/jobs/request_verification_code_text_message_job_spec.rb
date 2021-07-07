require "rails_helper"

RSpec.describe RequestVerificationCodeTextMessageJob, type: :job do
  before do
    allow(ClientLoginsService).to receive(:request_text_message_verification)
  end

  describe "#perform" do
    it "requests an email login from the client logins service" do
      RequestVerificationCodeTextMessageJob.perform_now(sms_phone_number: "+15105551234", visitor_id: "87h2897gh2", locale: "es")

      expect(ClientLoginsService).to have_received(:request_text_message_verification).with(
        sms_phone_number: "+15105551234",
        visitor_id: "87h2897gh2",
        locale: "es"
      )
    end
  end
end
