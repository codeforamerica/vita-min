require "rails_helper"

RSpec.describe Hub::TakeActionForm do
  let(:client) { intake.client }

  describe "#language_difference_help_text" do
    context "when the locale is different from the client's preferred interview language" do
      let(:intake) { create :intake, preferred_interview_language: "fr" }
      let(:form) { Hub::TakeActionForm.new(client, locale: "es") }

      it "returns the help text string with appropriate values" do
        expect(form.language_difference_help_text).to eq "This client requested French for their interview"
      end
    end

    context "when the locale and preferred interview language match" do
      let(:intake) { create :intake, preferred_interview_language: "es" }
      let(:form) { Hub::TakeActionForm.new(client, locale: "es") }

      it "returns nil" do
        expect(form.language_difference_help_text).to be_nil
      end
    end

    context "without a preferred interview language" do
      let(:intake) { create :intake, preferred_interview_language: nil }
      let(:form) { Hub::TakeActionForm.new(client, locale: "es") }

      it "returns nil" do
        expect(form.language_difference_help_text).to be_nil
      end
    end
  end

  describe "#contact_method_help_text" do
    let(:form) { Hub::TakeActionForm.new(client) }

    context "when the client prefers a specific contact method over others" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "no" }

      it "returns help text explaining the client's contact preferences" do
        expect(form.contact_method_help_text).to eq "This client prefers text message instead of email"
      end
    end

    context "when the client doesn't have contact preferences" do
      let(:intake) { create :intake, sms_notification_opt_in: "unfilled", email_notification_opt_in: "unfilled" }

      it "returns nil" do
        expect(form.contact_method_help_text).to be_nil
      end
    end

    context "when the client opts in to both methods" do
      let(:intake) { create :intake, sms_notification_opt_in: "yes", email_notification_opt_in: "yes" }

      it "returns nil" do
        expect(form.contact_method_help_text).to be_nil
      end
    end
  end

  describe "#contact_method_options" do
    let(:form) { Hub::TakeActionForm.new(client) }
    before do
      allow(I18n).to receive(:t).with("general.email").and_return("Email message")
      allow(I18n).to receive(:t).with("general.text_message").and_return("Text message")
    end

    context "with a client opted-in to just email" do
      let(:intake) { create :intake, email_notification_opt_in: "yes" }

      it "shows only email as a contact option" do
        expect(form.contact_method_options).to eq([{value: "email", label: "Email message"}])
      end
    end

    context "with a client opted-in to both email and text message" do
      let(:intake) { create :intake, email_notification_opt_in: "yes", sms_notification_opt_in: "yes" }

      it "shows only text message as a contact option" do
        expect(form.contact_method_options).to eq([{value: "email", label: "Email message"}, {value: "text_message", label: "Text message"}])
      end
    end

    context "with a client that hasn't opted into anything" do
      let(:intake) { create :intake }

      it "raises an error" do
        expect do
          form.contact_method_options
        end.to raise_error(StandardError, "Client has not opted in to any communications")
      end
    end
  end
end
