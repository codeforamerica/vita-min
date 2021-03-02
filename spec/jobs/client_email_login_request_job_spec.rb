require "rails_helper"

RSpec.describe ClientEmailLoginRequestJob, type: :job do
  before do
    allow(ClientLoginsService).to receive(:request_email_login)
  end

  describe "#perform" do
    it "requests an email login from the client logins service" do
      ClientEmailLoginRequestJob.perform_now(email_address: "client@example.com", visitor_id: "87h2897gh2", locale: "es")

      expect(ClientLoginsService).to have_received(:request_email_login).with(
        email_address: "client@example.com",
        visitor_id: "87h2897gh2",
        locale: "es"
      )
    end
  end
end
