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
      allow(ReplacementParametersService).to receive(:new).and_return(fake_replacement_parameters_service)
      allow(fake_replacement_parameters_service).to receive(:process_sensitive_data).and_return(sensitive_body)
    end

    it "delivers the email with the right subject, and processes sensitive parameters in the body" do
      email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)
      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      expect(ReplacementParametersService).to have_received(:new).with(
        body: outgoing_email.body,
        client: outgoing_email.client,
        locale: intake.locale
      )
      expect(fake_replacement_parameters_service).to have_received(:process_sensitive_data)

      expect(email.subject).to eq outgoing_email.subject
      expect(email.from).to eq ["no-reply@test.localhost"]
      expect(email.to).to eq [outgoing_email.to]
      expect(email.text_part.decoded.strip).to eq sensitive_body.strip
      expect(email.html_part.decoded).to have_selector('div', text: "Line 1")
      expect(email.html_part.decoded).to have_selector('div', text: "Secret Link")
    end

    context "with attachment" do
      let(:attachment) { fixture_file_upload("attachments/test-pattern.png") }

      it "includes the attachment in the email" do
        email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)

        expect(email.attachments.length).to eq 1
      end
    end

    context "without attachment" do
      it "can send" do
        email = OutgoingEmailMailer.user_message(outgoing_email: outgoing_email)
        expect do
          email.deliver_now
        end.to change(ActionMailer::Base.deliveries, :count).by 1
        expect(email.attachments.length).to eq 0
      end
    end
  end
end
