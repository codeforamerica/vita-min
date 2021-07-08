require "rails_helper"

RSpec.describe RequestVerificationCodeEmailJob, type: :job do
  before do
    allow(EmailVerificationCodeService).to receive(:request_code)
  end

  describe "#perform" do

    context "with email_address, visitor_id, and locale params" do
      it "requests a verification code by email using those params" do
        RequestVerificationCodeEmailJob.perform_now(email_address: "client@example.com", visitor_id: "87h2897gh2", locale: "es", service_type: :gyr)

        expect(EmailVerificationCodeService).to have_received(:request_code).with(
          email_address: "client@example.com",
          visitor_id: "87h2897gh2",
          locale: "es",
          client_id: nil,
          service_type: :gyr
        )
      end
    end
  end
end
