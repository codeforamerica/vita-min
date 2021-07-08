require "rails_helper"

RSpec.describe RequestVerificationCodeTextMessageJob, type: :job do
  before do
    allow(TextMessageVerificationCodeService).to receive(:request_code)
  end

  describe "#perform" do
    it "requests a generated code from the TextMessageVerificationCodeService" do
      RequestVerificationCodeTextMessageJob.perform_now(phone_number: "+15105551234", visitor_id: "87h2897gh2", locale: "es", service_type: :ctc)

      expect(TextMessageVerificationCodeService).to have_received(:request_code).with(
        phone_number: "+15105551234",
        visitor_id: "87h2897gh2",
        locale: "es",
        service_type: :ctc,
        client_id: nil
      )
    end
  end
end
