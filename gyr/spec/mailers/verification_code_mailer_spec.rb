require "rails_helper"

describe VerificationCodeMailer, type: :mailer do
  context "#with_code" do
    it "delivers the mail with the right subject and body from no-reply" do
      email = described_class.with(
        to: "example@example.com",
        locale: :en,
        service_type: :gyr
      ).with_code

      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      expect(email.subject).to eq "Update from GetYourRefund"
      expect(email.from).to eq ["no-reply@test.localhost"]
      expect(email.to).to eq ["example@example.com"]
      expect(email.text_part.decoded.strip).to include "GetYourRefund"
    end

    context "for a CTC client" do
      it "delivers an email with CTC branding and a no-reply@ address" do
        email = described_class.with(
          to: "example@example.com",
          locale: :en,
          service_type: :ctc
        ).with_code

        expect do
          email.deliver_now
        end.to change(ActionMailer::Base.deliveries, :count).by 1

        expect(email.subject).to eq "Update from GetCTC"
        expect(email.from).to eq ["no-reply@ctc.test.localhost"]
        expect(email.to).to eq ["example@example.com"]
        expect(email.text_part.decoded.strip).to include "GetCTC"
      end
    end
  end

  context "#no_match_found" do
    it 'delivers the mail with the right subject and body' do
      email = described_class.no_match_found(
        to: "example@example.com",
        locale: :en,
        service_type: :gyr
      )
      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      expect(email.subject).to eq "GetYourRefund Login Attempt"
      expect(email.from).to eq ["no-reply@test.localhost"]
      expect(email.to).to eq ["example@example.com"]
      expect(email.text_part.decoded.strip).to include "GetYourRefund"
    end
  end
end
