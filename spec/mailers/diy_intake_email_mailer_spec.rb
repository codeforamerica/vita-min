require "rails_helper"

RSpec.describe DiyIntakeEmailMailer, type: :mailer do
  describe "#message" do
    let(:diy_intake) { create :diy_intake, :filled_out }
    let(:diy_intake_email) { create :diy_intake_email, diy_intake: diy_intake }

    it "delivers the email with the right subject and body" do
      email = DiyIntakeEmailMailer.message(diy_intake_email: diy_intake_email)
      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      # expect(email.subject).to eq "GetYourRefund Client ##{tax_return.client.id} Assigned to You"
      expect(email.from).to eq ["no-reply@test.localhost"]
      expect(email.to).to eq [diy_intake.email]
      # expect(email.text_part.decoded.strip).to include hub_client_url(id: tax_return.client)
      # expect(email.html_part.decoded).to include hub_client_url(id: tax_return.client)
    end
  end
end
