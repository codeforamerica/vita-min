require "rails_helper"

RSpec.describe DiyIntakeEmailMailer, type: :mailer do
  describe "#high_support_message" do
    let(:diy_intake) { create :diy_intake, :filled_out }

    it "delivers the email with the right subject and body" do
      email = DiyIntakeEmailMailer.high_support_message(diy_intake: diy_intake)
      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      expect(email.subject).to eq I18n.t("high_support_mailer.subject", locale: :es)
      expect(email.from).to eq ["hello@test.localhost"]
      expect(email.to).to eq [diy_intake.email_address]
    end

    it_behaves_like "a mailer with an unsubscribe link" do
      let(:mail_method) { :high_support_message }
      let(:mailer_args) { { diy_intake: diy_intake } }
      let(:email_address) { diy_intake.email_address }
    end
  end
end
