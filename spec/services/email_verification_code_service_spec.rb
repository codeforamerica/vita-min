require "rails_helper"

describe EmailVerificationCodeService do
  let(:email_address) { "example@example.com" }
  let(:locale) { "en" }
  let(:visitor_id) { "visitor_id_1" }
  let(:client_id) { nil }
  let(:service_type) { nil }
  let(:params) do
    {
        email_address: email_address,
        locale: locale,
        visitor_id: visitor_id,
        client_id: client_id,
        service_type: service_type
    }
  end
  describe "initialization" do
    context "service_type" do
      let(:service_type) { :unsupported }
      it "raises an error if service_type is not in the list" do
        expect {
          described_class.new(**params)
        }.to raise_error ArgumentError, "Unsupported service_type: unsupported"
      end
    end
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

    context "when service_type is ctc" do
      let(:service_type) { :ctc }
      it "creates a VerificationEmail, sends an email, and creates an EmailAccessToken object" do
        expect {
          described_class.request_code(**params)
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include "Your 6-digit GetCTC verification code is: 123456"
        expect(EmailAccessToken).to have_received(:generate!).with(a_hash_including(
                                                                   email_address: email_address,
                                                                   client_id: nil,
                                                                 ))
        expect(VerificationEmail).to have_received(:create!).with(a_hash_including(
                                                                      email_access_token: access_token_double,
                                                                      visitor_id: visitor_id,
                                                                      mailgun_id: "mocked_mailer_id"
                                                                  ))
      end
    end
    context "when service type is GYR" do
      let(:service_type) { :gyr }
      it "the resulting email includes GetYourRefund" do
        described_class.request_code(**params)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include "Your 6-digit GetYourRefund verification code is: 123456"
      end
    end

    context "when service type is CTC" do
      let(:service_type) { :ctc }
      it "the resulting email includes GetCTC" do
        described_class.request_code(**params)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include "Your 6-digit GetCTC verification code is: 123456"
      end
    end




  end
end