require "rails_helper"

describe ArchivedIntakeEmailVerificationCodeService do
  let(:email_address) { "example@example.com" }
  let(:locale) { "en" }

  let(:params) do
    {
      email_address: email_address,
      locale: locale
    }
  end

  describe ".request_code" do
    let(:mailer_double) { double VerificationCodeMailer }
    let(:access_token_double) { double EmailAccessToken }
    let(:mocked_job_response) { double }
    before do
      allow(EmailAccessToken).to receive(:generate!).and_return(["123456", access_token_double])
      allow(VerificationEmail).to receive(:create!)
      allow(mailer_double).to receive(:perform_now).and_return(mocked_job_response)
      allow_any_instance_of(Mail::Message).to receive(:message_id).and_return("mocked_mailer_id")
      allow(DatadogApi).to receive(:increment)
    end


    context "when locale is English" do
      let(:service_type) { :statefile }

      it "sends an email that includes 'FileYourStateTaxes'" do
        described_class.request_code(**params)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include "Your six-digit verification code for FileYourStateTaxes is: 123456"
      end
    end

    context 'when locale is Spanish' do
      let(:locale) { :es }

      it "sends an email that includes 'FileYourStateTaxes'" do
        described_class.request_code(**params)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include ("Tu equipo de impuestos en FileYourStateTaxes.org")
        expect(email.body.encoded).to include ("123456")
      end
    end
  end

  context "email address has an extra space" do
    let(:email_address) { "example@example.com " }

    it "strips the whitespace before generating the token instead of throwing an error" do
      described_class.request_code(**params)
      access_token = EmailAccessToken.last
      expect(access_token.email_address).to eq "example@example.com"
    end
  end
end
