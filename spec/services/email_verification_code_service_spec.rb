require "rails_helper"

describe EmailVerificationCodeService do
  let(:email_address) { "example@example.com" }
  let(:locale) { "en" }
  let(:visitor_id) { "visitor_id_1" }
  let(:client_id) { nil }
  let(:verification_type) { nil }
  let(:params) do
    {
        email_address: email_address,
        locale: locale,
        visitor_id: visitor_id,
        client_id: client_id,
        verification_type: verification_type
    }
  end
  describe "initialization" do
    context "verification_type" do
      let(:verification_type) { :unsupported }
      it "raises an error if verification_type is not in the list" do
        expect {
          described_class.new(**params)
        }.to raise_error ArgumentError, "Unsupported verification type: unsupported"
      end
    end
  end

  describe ".request_code" do
    let(:mailer_double) { double VerificationCodeMailer }
    let(:access_token_double) { double EmailAccessToken }
    let(:mocked_job_response) { double }
    before do
      allow(EmailAccessToken).to receive(:create!).and_return(access_token_double)
      allow(VerificationEmail).to receive(:create!)
      allow(mailer_double).to receive(:perform_now).and_return(mocked_job_response)
      allow(VerificationCodeService).to receive(:generate).and_return ["123456", "hashed_verification_code"]
      allow_any_instance_of(Mail::Message).to receive(:message_id).and_return("mocked_mailer_id")
      allow(DatadogApi).to receive(:increment)
    end

    context "when verification_type is ctc_intake" do
      let(:verification_type) { :ctc_intake }
      it "creates a VerificationEmail, sends an email, and creates an EmailAccessToken object" do
        expect {
          described_class.request_code(**params)
        }.to change(ActionMailer::Base.deliveries, :count).by(1)
        email = ActionMailer::Base.deliveries.last
        expect(email.to).to eq [email_address]
        expect(email.body.encoded).to include "Your 6-digit GetCTC verification code is: 123456"
        expect(EmailAccessToken).to have_received(:create!).with(a_hash_including(
                                                                   email_address: email_address,
                                                                   client_id: nil,
                                                                   token_type: "verification_code",
                                                                   token: Devise.token_generator.digest(EmailAccessToken, :token, "hashed_verification_code")
                                                                 ))
        expect(VerificationEmail).to have_received(:create!).with(a_hash_including(
                                                                    visitor_id: visitor_id,
                                                                    email_access_token: access_token_double,
                                                                    mailgun_id: "mocked_mailer_id"
                                                                  ))
        expect(DatadogApi).to have_received(:increment).with "client_logins.verification_codes.email.created"
      end
    end

    context "when verification type is :gyr_login" do
      let(:matching_intakes) { double }
      let(:verification_type) { :gyr_login }
      context "when the client email is found" do
        before do
          allow(ClientLoginsService).to receive(:accessible_intakes).and_return(matching_intakes)
          allow(matching_intakes).to receive(:where).and_return(matching_intakes)
          allow(matching_intakes).to receive(:or).and_return(matching_intakes)
          allow(matching_intakes).to receive(:exists?).and_return(true)
        end

        it "creates a VerificationEmail, sends an email, and creates an EmailAccessToken object" do
          expect {
            described_class.request_code(**params)
          }.to change(ActionMailer::Base.deliveries, :count).by(1)
          email = ActionMailer::Base.deliveries.last
          expect(email.to).to eq [email_address]
          expect(email.body.encoded).to include "Your 6-digit GetYourRefund verification code is: 123456"
          expect(EmailAccessToken).to have_received(:create!).with(a_hash_including(
                                                                     email_address: email_address,
                                                                     client_id: nil,
                                                                     token_type: "verification_code",
                                                                     token: Devise.token_generator.digest(EmailAccessToken, :token, "hashed_verification_code")
                                                                   ))
          expect(VerificationEmail).to have_received(:create!).with(a_hash_including(
                                                                      visitor_id: visitor_id,
                                                                      email_access_token: access_token_double,
                                                                      mailgun_id: "mocked_mailer_id"
                                                                    ))
          expect(DatadogApi).to have_received(:increment).with "client_logins.verification_codes.email.created"

        end
      end

      context "when the client email is not found" do
        let(:verification_type) { :gyr_login }
        let(:locale) { "es" }
        it "sends the no match email and does not create accompanying objects" do
          expect {
            described_class.request_code(**params)
          }.to change(ActionMailer::Base.deliveries, :count).by(1)
          email = ActionMailer::Base.deliveries.last
          expect(email.body.encoded).to include("acceder a GetYourRefund")
          expect(VerificationEmail).not_to have_received(:create!)
          expect(EmailAccessToken).not_to have_received(:create!)
          expect(DatadogApi).not_to have_received(:increment)
        end
      end
    end
  end
end