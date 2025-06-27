require "rails_helper"

RSpec.describe ClientMessagingService do
  let(:email_opt_in) { "yes" }
  let(:sms_opt_in) { "yes" }
  let(:email_address) { "client@example.com" }
  let(:sms_phone_number) { "+14155551212" }
  let(:intake) { create :intake,
                        preferred_name: "Mona Lisa",
                        email_address: email_address,
                        sms_phone_number: sms_phone_number,
                        email_notification_opt_in: email_opt_in,
                        sms_notification_opt_in: sms_opt_in
  }
  let!(:client) { intake.client }
  let!(:user) { create :user }
  let(:expected_time) { DateTime.new(2020, 9, 9) }

  before do
    allow(DateTime).to receive(:now).and_return(expected_time)
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  describe ".send_email", active_job: true do
    context "when user is nil" do
      context "with a GYR intake" do
        it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
          expect do
            described_class.send_email(client: client, user: nil, body: "hello from a system email")
          end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

          outgoing_email = OutgoingEmail.last
          expect(outgoing_email.subject).to eq("Update from GetYourRefund")
          expect(outgoing_email.body).to eq("hello from a system email")
          expect(outgoing_email.client).to eq client
          expect(outgoing_email.user).to eq nil
          expect(outgoing_email.to).to eq client.email_address
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
        end

        context "when the user has not opted-in" do
          let(:email_opt_in) { "no" }

          it "does not send a message" do
            expect do
              described_class.send_email(client: client, user: nil, body: "hello from a system email")
            end.not_to change(OutgoingEmail, :count)
          end
        end
      end
    end

    context "when user is present" do
      context "with a GYR intake" do
        it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
          expect do
            described_class.send_email(client: client, user: user, body: "hello, <<Client.PreferredName>>")
          end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

          outgoing_email = OutgoingEmail.last
          expect(outgoing_email.subject).to eq("Update from GetYourRefund")
          expect(outgoing_email.body).to eq("hello, Mona Lisa")
          expect(outgoing_email.client).to eq client
          expect(outgoing_email.user).to eq user
          expect(outgoing_email.to).to eq client.email_address
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
        end
      end

      context "with blank body" do
        it "raises an error" do
          expect do
            described_class.send_email(client: client, user: user, body: " \n")
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "with an attachment" do
        let(:attachment) { fixture_file_upload("test-pattern.png") }

        it "saves the attachment" do
          described_class.send_email(client: client, user: user, body: "hello", attachment: attachment)

          expect(OutgoingEmail.last.attachment).to be_present
        end
      end

      context "with a custom subject locale" do
        it "uses that locale" do
          described_class.send_email(client: client, user: user, body: "hola", locale: "es")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end

      context "with a client whose locale differs from the current request" do
        before { intake.update(locale: "es") }

        it "uses the client locale" do
          described_class.send_email(client: client, user: user, body: "hola")
          expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
        end
      end

      context "replacing parameters" do
        let(:param_double) { double(ReplacementParametersService) }
        let(:body) { "raw body" }
        before do
          allow(ReplacementParametersService).to receive(:new).and_return param_double
          allow(param_double).to receive(:process).and_return "replaced body"
        end

        it "processed with ReplacementParametersService and persists the replaced body" do
          described_class.send_email(client: client, user: user, body: body)
          expect(ReplacementParametersService).to have_received(:new).with(client: client, preparer: user, body: body, tax_return: nil, locale: nil)
          expect(OutgoingEmail.last.body).to eq "replaced body"
        end
      end

      context "when the client has opted into messaging but did not provide an email" do
        let(:email_opt_in) { "yes" }
        let(:email_address) { nil }
        before do
          allow(DatadogApi).to receive(:increment).with('clients.missing_email_for_email_opt_in')
        end

        it "does not send an email but should increment datadog metric by 1" do
          expect do
            described_class.send_email(client: client, user: user, body: "hello")
            expect(DatadogApi).to have_received(:increment).with('clients.missing_email_for_email_opt_in')
          end.to change(OutgoingEmail, :count).by(0)
        end
      end

      context "when the client has not opted into email messaging" do
        let(:email_opt_in) { "no" }
        let(:email_address) { nil }
        it "returns false and does not send an email" do
          expect do
            return_value = described_class.send_email(client: client, user: user, body: "hello")
            expect(return_value).to be_nil
          end.to change(OutgoingEmail, :count).by(0)
        end
      end
    end
  end

  describe ".send_email_to_all_signers", active_job: true do
    context "when user is nil" do
      it "raises an error" do
        expect do
          described_class.send_email_to_all_signers(client: client, body: "hello")
        end.to raise_error(ArgumentError, "missing keyword: :user")
      end
    end

    context "when user is present" do
      context "when the client has opted into email" do
        let(:email_opt_in) { "yes" }

        it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
          expect do
            described_class.send_email_to_all_signers(client: client, user: user, body: "hello")
          end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

          outgoing_email = OutgoingEmail.last
          expect(outgoing_email.subject).to eq("Update from GetYourRefund")
          expect(outgoing_email.body).to eq("hello")
          expect(outgoing_email.client).to eq client
          expect(outgoing_email.user).to eq user
          expect(outgoing_email.to).to eq client.email_address
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)
        end

        context "when the client is filing joint" do
          let(:intake) do
            create :intake, email_address: "client@example.com", spouse_email_address: "spouse@example.com", filing_joint: "yes", email_notification_opt_in: "yes"
          end

          it "includes the spouse email in the 'to' field" do
            described_class.send_email_to_all_signers(client: client, user: user, body: "hello")

            expect(OutgoingEmail.last.to).to eq "client@example.com,spouse@example.com"
          end
        end

        context "with an attachment" do
          let(:attachment) { fixture_file_upload("test-pattern.png") }

          it "saves the attachment" do
            described_class.send_email_to_all_signers(client: client, user: user, body: "hello", attachment: attachment)

            expect(OutgoingEmail.last.attachment).to be_present
          end
        end

        context "with a custom subject locale" do
          it "uses that locale" do
            described_class.send_email_to_all_signers(client: client, user: user, body: "hola", locale: "es")
            expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
          end
        end

        context "with a client whose locale differs from the current request" do
          before { intake.update(locale: "es") }

          it "uses the client locale" do
            described_class.send_email_to_all_signers(client: client, user: user, body: "hola")
            expect(OutgoingEmail.last.subject).to eq "Actualización de GetYourRefund"
          end
        end
      end
    end
  end

  describe ".send_system_email", active_job: true do
    it "saves a new outgoing email with the right info, enqueues email job, and broadcasts to ClientChannel" do
      expect do
        described_class.send_system_email(client: client, body: "hello", subject: "subject")
      end.to change(OutgoingEmail, :count).by(1).and have_enqueued_job(SendOutgoingEmailJob)

      system_email = OutgoingEmail.last
      expect(system_email.subject).to eq("subject")
      expect(system_email.body).to eq("hello")
      expect(system_email.client).to eq client
      expect(system_email.to).to eq client.email_address
      expect(ClientChannel).to have_received(:broadcast_contact_record).with(system_email)
    end

    context "with blank body" do
      it "raises an error" do
        expect do
          described_class.send_system_email(client: client, body: " \n", subject: "subject")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with blank subject" do
      it "raises an error" do
        expect do
          described_class.send_system_email(client: client, body: "body", subject: " \n")
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe ".send_text_message", active_job: true do
    before do
      allow(DatadogApi).to receive(:increment).with("clients.missing_sms_phone_number_for_sms_opt_in")
    end

    context "when user is nil" do
      context "with a GYR intake" do
        it "saves a new outgoing text message with the right info, enqueues job, and broadcasts to ClientChannel" do
          expect do
            described_class.send_text_message(client: client, user: nil, body: "hello, <<Client.PreferredName>>")
          end.to change(OutgoingTextMessage, :count).by(1)

          outgoing_text_message = OutgoingTextMessage.last
          expect(outgoing_text_message.body).to eq("hello, Mona Lisa")
          expect(outgoing_text_message.client).to eq client
          expect(outgoing_text_message.user).to eq nil
          expect(outgoing_text_message.sent_at).to eq expected_time
          expect(outgoing_text_message.to_phone_number).to eq client.sms_phone_number
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_text_message)
          expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
        end

        context "when the user has not opted-in" do
          let(:sms_opt_in) { "no" }

          it "does not send a message" do
            expect do
              described_class.send_text_message(client: client, user: nil, body: "hello from a system email")
            end.not_to change(OutgoingTextMessage, :count)
          end
        end
      end

      context "with an archived intake" do
        let!(:intake) { create :archived_intakes_2021,
                               preferred_name: "Mona Lisa",
                               sms_phone_number: sms_phone_number,
                               sms_notification_opt_in: sms_opt_in
        }

        it "saves a new outgoing text message with the right info, enqueues job, and broadcasts to ClientChannel" do
          expect do
            described_class.send_text_message(client: client, user: nil, body: "hello, <<Client.PreferredName>>")
          end.to change(OutgoingTextMessage, :count).by(1)

          outgoing_text_message = OutgoingTextMessage.last
          expect(outgoing_text_message.body).to eq("hello, Mona Lisa")
          expect(outgoing_text_message.client).to eq client
          expect(outgoing_text_message.user).to eq nil
          expect(outgoing_text_message.sent_at).to eq expected_time
          expect(outgoing_text_message.to_phone_number).to eq intake.sms_phone_number
          expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_text_message)
          expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
        end
      end
    end

    context "when user is present" do
      it "saves a new outgoing text message with the right info, enqueues job, and broadcasts to ClientChannel" do
        expect do
          described_class.send_text_message(client: client, user: user, body: "hello, <<Client.PreferredName>>")
        end.to change(OutgoingTextMessage, :count).by(1)

        outgoing_text_message = OutgoingTextMessage.last
        expect(outgoing_text_message.body).to eq("hello, Mona Lisa")
        expect(outgoing_text_message.client).to eq client
        expect(outgoing_text_message.user).to eq user
        expect(outgoing_text_message.sent_at).to eq expected_time
        expect(outgoing_text_message.to_phone_number).to eq client.sms_phone_number
        expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_text_message)
        expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(outgoing_text_message.id)
      end

      context "with blank body" do
        it "raises an error" do
          expect do
            described_class.send_text_message(client: client, user: user, body: " \n")
          end.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "replacing parameters" do
        let(:param_double) { double(ReplacementParametersService) }
        let(:body) { "raw body" }
        before do
          allow(ReplacementParametersService).to receive(:new).and_return param_double
          allow(param_double).to receive(:process).and_return "replaced body"
        end

        it "processed with ReplacementParametersService and persists the replaced body" do
          described_class.send_text_message(client: client, user: user, body: body)
          expect(ReplacementParametersService).to have_received(:new).with(client: client, preparer: user, body: body, tax_return: nil, locale: nil)
          expect(OutgoingTextMessage.last.body).to eq "replaced body"
        end
      end

      context "when they are opted into sms but lack a phone number" do
        let(:sms_opt_in) { "yes" }
        let(:sms_phone_number) { "" }

        it "does not send a message and increments data dog" do
          expect do
            described_class.send_text_message(client: client, user: user, body: "hello")
            expect(DatadogApi).to have_received(:increment).with("clients.missing_sms_phone_number_for_sms_opt_in")
          end.to change(OutgoingTextMessage, :count).by(0)
        end
      end

      context "when they are not opted into sms" do
        let(:sms_opt_in) { "no" }
        it "returns false, does not send a message or increment" do
          expect do
            return_value = described_class.send_text_message(client: client, user: user, body: "hello")
            expect(return_value).to be_nil
            expect(DatadogApi).not_to have_received(:increment).with("clients.missing_sms_phone_number_for_sms_opt_in")
          end.to change(OutgoingTextMessage, :count).by(0)
        end
      end
    end
  end

  describe ".send_system_text_message", active_job: true do
    it "saves a new system text message with the right info, enqueues job, and broadcasts to ClientChannel" do
      expect do
        described_class.send_system_text_message(client: client, body: "hello")
      end.to change(OutgoingTextMessage, :count).by(1)

      system_text_message = OutgoingTextMessage.last
      expect(system_text_message.body).to eq("hello")
      expect(system_text_message.client).to eq client
      expect(system_text_message.sent_at).to eq expected_time
      expect(system_text_message.to_phone_number).to eq client.sms_phone_number
      expect(ClientChannel).to have_received(:broadcast_contact_record).with(system_text_message)
      expect(SendOutgoingTextMessageJob).to have_been_enqueued.with(system_text_message.id)
    end
  end

  describe ".send_system_message_to_all_opted_in_contact_methods", active_job: true do
    let(:tax_return) { create :gyr_tax_return }
    let(:automated_message_double) { double }
    before do
      allow(SendAutomatedMessage).to receive(:new).and_return(automated_message_double)
      allow(automated_message_double).to receive(:send_messages)
    end

    it "calls the SendAutomatedMessage class with params" do
      described_class.send_system_message_to_all_opted_in_contact_methods(
        client: client,
        message: AutomatedMessage::SuccessfulSubmissionDropOff,
        locale: "es",
        tax_return: tax_return
      )

      expect(SendAutomatedMessage).to have_received(:new).with(
        client: client,
        message: AutomatedMessage::SuccessfulSubmissionDropOff,
        locale: "es",
        tax_return: tax_return,
        body_args: {}
      )

      expect(automated_message_double).to have_received(:send_messages)
    end
  end

  describe ".contact_methods" do
    context "with a client opted-in to email" do
      let(:client) { create(:intake, email_address: email_address, email_notification_opt_in: "yes").client }
      context "when the client has an email address" do
        let(:email_address) { "example@example.com" }

        it "returns the email address" do
          expect(described_class.contact_methods(client)).to eq({ email: "example@example.com" })
        end
      end

      context "when the client has no email address" do
        let(:email_address) { nil }

        it "returns an empty hash" do
          expect(described_class.contact_methods(client)).to eq({})
        end
      end
    end

    context "with a client opted-in to nothing" do
      let(:client) { create(:intake).client }

      it "returns an empty hash" do
        expect(described_class.contact_methods(client)).to eq({})
      end
    end

    context "with a client opted-in to sms" do
      let(:client) { create(:intake, sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes").client }
      context "when the client has an sms number" do
        let(:sms_phone_number) { "+14155551212" }

        it "returns the number" do
          expect(described_class.contact_methods(client)).to eq({ sms_phone_number: "+14155551212" })
        end
      end

      context "when the client has no sms number" do
        let(:sms_phone_number) { nil }

        it "returns an empty hash" do
          expect(described_class.contact_methods(client)).to eq({})
        end
      end
    end

    context "with a client opted-in to both" do
      let(:client) { create(:intake, email_address: email_address, sms_phone_number: sms_phone_number, email_notification_opt_in: "yes", sms_notification_opt_in: "yes").client }
      context "when the client has an sms number and email address" do
        let(:email_address) { "example@example.com" }
        let(:sms_phone_number) { "+14155551212" }

        it "returns both, email address first" do
          contact_methods = described_class.contact_methods(client)
          expect(contact_methods).to eq({ email: "example@example.com", sms_phone_number: "+14155551212" })
          expect(contact_methods.keys.first).to eq(:email)
        end
      end
    end
  end
end
