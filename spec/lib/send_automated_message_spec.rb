require "rails_helper"

describe SendAutomatedMessage, active_job: true do
  let(:intake) { create :intake, preferred_name: "Mona Lisa", email_address: "client@example.com", sms_phone_number: "+14155551212" }
  let(:email_body) { "heyo" }
  let(:sms_body) { "hi!" }
  let(:subject) { "email subject" }
  let(:client) { intake.client }

  context "when the client has not opted in to anything" do
    let(:intake) { create :intake, sms_notification_opt_in: "no", email_notification_opt_in: "no" }

    it "returns a hash with nil for both message record types" do
      expect(described_class.new(client: client, message: AutomatedMessage::GettingStarted.new, locale: 'en').send_messages)
          .to eq([])
    end
  end

  context "when client has opted in to email and has an email_address" do
    let(:intake) { create :intake, sms_notification_opt_in: "no", email_notification_opt_in: "yes", email_address: "something@example.com" }
    let(:outgoing_email) { build :outgoing_email }
    before do
      allow(ClientMessagingService).to receive(:send_system_email).and_return(outgoing_email)
    end

    it "returns a hash with the output of send_email as the value for outgoing_email" do
      getting_started_message = AutomatedMessage::GettingStarted.new
      expect(described_class.new(client: client, message: getting_started_message, locale: 'en').send_messages)
          .to eq [outgoing_email]
      expect(ClientMessagingService).to have_received(:send_system_email).with(tax_return: nil, client: client, body: getting_started_message.email_body, subject: getting_started_message.email_subject, locale: 'en')
    end
  end

  context "when the client has opted into sms and has an sms_phone_number" do
    let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no", sms_phone_number: "+14155551212" }
    let(:outgoing_text_message) { build :outgoing_text_message }
    before do
      allow(ClientMessagingService).to receive(:send_system_text_message).and_return(outgoing_text_message)
    end

    it "returns a hash with the output of send_text_message as the value for outgoing_text_message" do
      getting_started_message = AutomatedMessage::GettingStarted.new
      expect(described_class.new(client: client, message: getting_started_message, locale: "en").send_messages)
          .to eq [outgoing_text_message]
      expect(ClientMessagingService).to have_received(:send_system_text_message).with(tax_return: nil, client: client, body: getting_started_message.sms_body, locale: "en")
    end
  end

  context "when the client has opted into one contact method but lacks the contact info" do
    let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no", sms_phone_number: nil }

    it "returns a hash with nil as the value for contact record" do
      expect(described_class.new(client: client, message: AutomatedMessage::GettingStarted.new, locale: "es").send_messages)
          .to eq []
    end
  end

  context "when the client prefers both and has all the contact info" do
    let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes", sms_phone_number: "+14155551212", email_address: "client@example.com" }
    let(:outgoing_email) { build :outgoing_email }
    let(:outgoing_text_message) { build :outgoing_text_message }
    before do
      allow(ClientMessagingService).to receive(:send_system_email).and_return(outgoing_email)
      allow(ClientMessagingService).to receive(:send_system_text_message).and_return(outgoing_text_message)
    end

    it "returns a hash containing all contact records" do
      getting_started_message = AutomatedMessage::GettingStarted.new
      expect(described_class.new(client: client, message: getting_started_message, locale: "es").send_messages)
          .to eq [outgoing_email, outgoing_text_message]

      expect(ClientMessagingService).to have_received(:send_system_email).with(tax_return: nil, client: client, body: getting_started_message.email_body(locale: "es"), subject: getting_started_message.email_subject(locale: "es"), locale: "es")
      expect(ClientMessagingService).to have_received(:send_system_text_message).with(tax_return: nil, client: client, body: getting_started_message.sms_body(locale: "es"), locale: "es")
    end
  end

  context "when the client prefers both but only has contact info for one" do
    let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes", sms_phone_number: nil, email_address: "client@example.com" }
    let(:outgoing_email) { build :outgoing_email }
    before do
      allow(ClientMessagingService).to receive(:send_system_email).and_return(outgoing_email)
    end

    it "returns an array with an outgoing email object" do
      getting_started_message = AutomatedMessage::GettingStarted.new
      expect(described_class.new(client: client, message: getting_started_message, locale: "en").send_messages)
          .to eq [outgoing_email]
      expect(ClientMessagingService).to have_received(:send_system_email).with(tax_return: nil, client: client, body: getting_started_message.email_body, subject: getting_started_message.email_subject, locale: "en")
    end
  end
end