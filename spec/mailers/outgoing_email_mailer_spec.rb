require "rails_helper"

RSpec.describe OutgoingEmailMailer, type: :mailer do
  before do
    allow(ClientChannel).to receive(:broadcast_contact_record)
  end

  describe "#user_message" do
    let(:attachment) { nil }
    let(:outgoing_email) do
      create :outgoing_email, subject: "Update from GetYourRefund", body: body.chomp, to: "different@example.com", attachment: attachment
    end
    let(:built_email) do
      build :outgoing_email, subject: "Update from GetYourRefund", body: body.chomp, to: "different@example.com", attachment: attachment
    end
    let!(:intake) { create :intake, client: outgoing_email.client, locale: "en" }
    let(:body) do
      <<~BODY
        Line 1
        Secret Placeholder
      BODY
    end
    let(:sensitive_body) do
      <<~BODY
        Line 1
        Secret Link
      BODY
    end
    let(:fake_replacement_parameters_service) { double }

    before do
      allow(LoginLinkInsertionService).to receive(:insert_links).and_return(sensitive_body)
      allow(DatadogApi).to receive(:increment)
    end

    it "delivers the email with the right subject, and processes sensitive parameters in the body" do
      email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)
      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      expect(LoginLinkInsertionService).to have_received(:insert_links).with(outgoing_email)

      expect(email.subject).to eq outgoing_email.subject
      expect(email.from).to eq ["no-reply@test.localhost"]
      expect(email.to).to eq [outgoing_email.to]
      expect(email.text_part.decoded.strip).to eq sensitive_body.strip
      expect(email.html_part.decoded).to have_selector('div', text: "Line 1")
      expect(email.html_part.decoded).to have_selector('div', text: "Secret Link")
    end

    it "sends a metric to Datadog" do
      OutgoingEmailMailer.user_message(outgoing_email: outgoing_email).deliver_now

      expect(DatadogApi).to have_received(:increment).with "mailgun.outgoing_emails.sent"
    end

    context "with attachment" do
      let(:attachment) { fixture_file_upload("attachments/test-pattern.png") }

      it "includes the attachment in the email" do
        email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)

        expect(email.attachments.length).to eq 2 # the attachment + the logo
      end
    end

    context "without attachment" do
      it "can send" do
        email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)
        expect do
          email.deliver_now
        end.to change(ActionMailer::Base.deliveries, :count).by 1
        expect(email.attachments.length).to eq 1 # the logo
      end
    end

    context "with a plain text link in the body" do
      let(:sensitive_body) { "Hi user, you need to visit https://example.com/ and then come back to https://getyourrefund.org/" }

      it "makes it into a link in the HTML part" do
        email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)
        expect(email.html_part.decoded).to have_selector("a[href=\"https://example.com/\"]", text: "https://example.com/")
        expect(email.html_part.decoded).to have_selector("a[href=\"https://getyourrefund.org/\"]", text: "https://getyourrefund.org/")
      end
    end
  end
end
