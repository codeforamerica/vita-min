require "rails_helper"

RSpec.describe ArchivedIntakeEmailVerificationCodeJob, type: :job do
  before do
    allow(ArchivedIntakeEmailVerificationCodeService).to receive(:request_code)
  end

  describe "#perform" do
    context "with email_address, visitor_id, and locale params" do
      it "requests a verification code by email using those params" do
        ArchivedIntakeEmailVerificationCodeJob.perform_now(email_address: "client@example.com", locale: "es")

        expect(ArchivedIntakeEmailVerificationCodeService).to have_received(:request_code).with(
          email_address: "client@example.com",
          locale: "es"
        )
      end
    end
  end
end
