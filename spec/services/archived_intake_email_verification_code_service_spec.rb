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

    context 'when locale is spanish' do

      let(:locale) { :es }

      xit "sends an email that includes 'FileYourStateTaxes'" do
        described_class.request_code(**params)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include (
                                                'Tu equipo de impuestos en FileYourStateT'
                                              )
      end
    end
  end
end