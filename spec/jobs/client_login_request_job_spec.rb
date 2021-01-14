require "rails_helper"

RSpec.describe ClientLoginRequestJob, type: :job do
  describe "#perform" do
    let(:email_address) { nil }
    let(:phone_number) { nil }

    context "when given no contact info" do
      it "raises an error" do
        expect do
          subject.perform(email_address: email_address, phone_number: phone_number)
        end.to raise_error(ArgumentError)
      end
    end

    context "with contact info" do
      let(:fake_time) { DateTime.new(2021, 1, 1) }
      before do
        allow(Devise.token_generator).to receive(:generate).and_return(['raw_token', 'encrypted_token'])
      end

      context "with an email" do
        let(:email_address) { "client@example.com" }

        context "with matching clients" do
          let!(:client) { create(:client, intake: create(:intake, email_address: email_address)) }

          xit "sends an email with a token link" do
            expect do
              subject.perform(email_address: email_address, phone_number: phone_number)
            end.to(have_enqueued_mail(ClientLoginRequestMailer, :token_link))
            expect(Devise.token_generator).to have_received(:generate).with(Client, :login_token)
            expect(client.reload.login_token).to eq('encrypted_token')
            expect(client.reload.login_requested_at).to eq(fake_time)
          end
        end

        context "without matching clients" do
          it "sends an email with helpful guidance" do
            expect do
              subject.perform(email_address: email_address, phone_number: phone_number)
            end.to have_enqueued_mail(ClientLoginRequestMailer, :no_match_found)
          end
        end
      end

      xcontext "with a phone number" do
        let(:phone_number) { "+15105551234" }

        xcontext "with matching clients" do
          let!(:client) { create(:client, intake: create(:intake, sms_phone_number: phone_number)) }
          before do
            subject.perform(email_address: email_address, phone_number: phone_number)
          end

          it "sends a text message with a token link" do
            expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(ClientLoginRequestTextMessage.last.id, system: true)
            text_message = ClientLoginRequestTextMessage.last
            expect(client.reload.login_token).to eq('encrypted_token')
            expect(text_message.body).to contain("raw_token") # We need to avoid storing this
            expect(text_message.client).to eq(client)
          end
        end

        xcontext "without matching clients" do
          it "sends a text message with helpful guidance" do
            expect(SendOutgoingTextMessageJob).to have_been_enqueued.with("something else")
          end
        end
      end

      xcontext "with matching clients" do
        before do
          subject.perform(email_address: email_address, phone_number: phone_number)
        end

        context "it sends" do
        end
      end

      xcontext "with no matching clients" do

      end
    end

    # find relevant clients
    # make tokens
    # send email if email present
    # send text message if phone number present
  end
end
