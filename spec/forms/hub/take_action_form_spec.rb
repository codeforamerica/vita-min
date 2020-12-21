require "rails_helper"

RSpec.describe Hub::TakeActionForm do
  let(:client) { intake.client }
  let(:current_user) { create :admin_user, name: "Marilyn Mango" }

  before do
    allow(SendOutgoingTextMessageJob).to receive(:perform_later)
    allow(ClientChannel).to receive(:broadcast_contact_record)
    allow(OutgoingEmailMailer).to receive_message_chain(:user_message, :deliver_later)
  end

  describe "setting default values" do
    let(:intake) { create :intake, locale: "es", preferred_name: "Luna Lemon" }
    context "default locale" do
      context "when not explicitly provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user) }
        it "uses client locale " do
          expect(form.locale).to eq "es"
        end
      end

      context "when provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user,{ locale: "en" })}
        it "uses provided locale" do
          expect(form.locale).to eq "en"
        end
      end

      context "when provided and is blank" do
        let(:form) { Hub::TakeActionForm.new(client, current_user,{ locale: "" }) }
        it "uses clients locale" do
          expect(form.locale).to eq client.intake.locale
        end
      end
    end

    context "default message body" do

      context "when a message body is provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user,{ message_body: "hi", status: "intake_needs_info" }) }
        it "does not overwrite the message body" do
          expect(form.message_body).to eq "hi"
        end
      end

      context "when a status and message body are not provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user) }

        it "sets message body as an empty string" do
          expect(form.message_body).to eq ""
        end
      end

      context "when a status that has a message template is provided and locale is english" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { status: "intake_more_info", locale: "en" }) }

        it "sets message body to the template with replacement parameters substituted" do
          expect(form.message_body).to start_with("Hello")
          expect(form.message_body).to include client.preferred_name
          expect(form.message_body).to include current_user.first_name
        end
      end

      context "when a status that has a message template is provided and locale is spanish" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { status: "intake_more_info", locale: "es" }) }
        let(:filled_out_template) {
          <<~MESSAGE
            ¡Hola Luna Lemon!

            Para continuar presentando sus impuestos, necesitamos que nos envíe:
              - Identificación
              - Selfie
              - SSN o ITIN
              - Otro
            Sube tus documentos de forma segura por https://example.com/my-token-link

            Por favor, háganos saber si usted tiene alguna pregunta. No podemos preparar sus impuestos sin esta información.

            ¡Gracias!
            Marilyn en GetYourRefund.org
          MESSAGE
        }

        before do
          allow(client.intake).to receive(:relevant_document_types).and_return [DocumentTypes::Identity, DocumentTypes::Selfie, DocumentTypes::SsnItin, DocumentTypes::Other]
          allow(client.intake).to receive(:requested_docs_token_link).and_return "https://example.com/my-token-link"
        end

        it "sets message body to the template with replacement parameters substituted" do
          expect(form.message_body).to eq filled_out_template
          expect(form.message_body).to include client.preferred_name
          expect(form.message_body).to include current_user.first_name
        end
      end

      context "when a status without a message template is provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { status: "non_matching_status"})}
        it "sets message body as an empty string" do
          expect(form.message_body).to eq ""
        end
      end
    end

    context "default contact method" do
      context "when contact method is provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { contact_method: "text_message" }) }

        it "uses the provided contact method" do
          expect(form.contact_method).to eq "text_message"
        end
      end

      context "when not provided" do
        context "when user prefers sms" do
          let(:form) { Hub::TakeActionForm.new(client, current_user) }

          before do
            allow(client.intake).to receive(:sms_notification_opt_in_yes?).and_return true
            allow(client.intake).to receive(:email_notification_opt_in_no?).and_return true
          end

          it "sets to sms" do
            expect(form.contact_method).to eq "text_message"
          end
        end

        context "when user does not only prefer sms" do
          let(:form) { Hub::TakeActionForm.new(client, current_user) }

          before do
            allow(client.intake).to receive(:sms_notification_opt_in_yes?).and_return true
            allow(client.intake).to receive(:email_notification_opt_in_no?).and_return false
          end

          it "sets to email" do
            expect(form.contact_method).to eq "email"
          end
        end
      end
    end
  end

  describe "#language_difference_help_text" do
    context "when the locale is different from the client's preferred interview language" do
      let(:intake) { create :intake, preferred_interview_language: "fr" }
      let(:form) { Hub::TakeActionForm.new(client, current_user, locale: "es") }

      it "returns the help text string with appropriate values" do
        expect(form.language_difference_help_text).to eq "This client requested French for their interview"
      end
    end

    context "when the locale and preferred interview language match" do
      let(:intake) { create :intake, preferred_interview_language: "es" }
      let(:form) { Hub::TakeActionForm.new(client, current_user, locale: "es") }

      it "returns nil" do
        expect(form.language_difference_help_text).to be_nil
      end
    end

    context "without a preferred interview language" do
      let(:intake) { create :intake, preferred_interview_language: nil }
      let(:form) { Hub::TakeActionForm.new(client, current_user, locale: "es") }

      it "returns nil" do
        expect(form.language_difference_help_text).to be_nil
      end
    end
  end

  describe "#contact_method_help_text" do
    let(:form) { Hub::TakeActionForm.new(client, current_user) }

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
    let(:form) { Hub::TakeActionForm.new(client, current_user) }
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
  describe "#take_action" do

    context "when tax_return_id is not part of clients tax returns" do
      let(:intake) { create :intake }
      let(:form) { Hub::TakeActionForm.new(client, current_user, { tax_return_id: create(:tax_return).id }) }

      it "add an error to the object" do
        form.take_action
        expect(form.errors[:tax_return_id]).to include "Can't update tax return unrelated to current client."
      end
    end

    context "when new status is same as current status" do
      let(:intake) { create :intake }
      let(:tax_return) { create :tax_return, client: client, year: 2019 }
      let(:form) { Hub::TakeActionForm.new(client, current_user, { status: tax_return.status, tax_return_id: tax_return.id }) }

      it "add an error to the object" do
        form.take_action
        expect(form.errors[:status]).to include "Can't initiate status change to current status."
      end
    end

    context "a successful action" do
      let(:intake) { create :intake, email_address: "client@exaple.com", sms_phone_number: "+18324658840" }
      let(:tax_return) { create :tax_return, client: client, year: 2019 }

      context "only status change" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { tax_return_id: tax_return.id, status: "intake_more_info", message_body: "" }) }

        it "changes the status of the client" do
          expect {
            form.take_action
            tax_return.reload
          }.to change(tax_return, :status).to "intake_more_info"
        end

        it "does not send an email" do
          expect {
            form.take_action
          }.not_to change(OutgoingEmail, :count)
        end

        it "does not send a text" do
          expect {
            form.take_action
          }.not_to change(OutgoingTextMessage, :count)
        end

        it "does not create a note" do
          expect {
            form.take_action
          }.not_to change(Note, :count)
        end

        it "creates an action list that only includes changing status" do
          form.take_action
          expect(form.action_list).to eq ["updated status"]
        end
      end

      context "status change with default message" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { tax_return_id: tax_return.id, status: "intake_more_info" }) }
        it "changes the status of the client" do
          expect(SystemNote).to receive(:create_status_change_note).with(current_user, tax_return)

          expect {
            form.take_action
            tax_return.reload
          }.to change(tax_return, :status).to "intake_more_info"
        end

        it "sends an email" do
          expect {
            form.take_action
          }.to change(OutgoingEmail, :count).by(1)
        end

        it "does not send a text" do
          expect {
            form.take_action
          }.not_to change(OutgoingTextMessage, :count)
        end

        context "when client has an sms preference" do
          before do
            allow(client.intake).to receive(:email_notification_opt_in_no?).and_return true
            allow(client.intake).to receive(:sms_notification_opt_in_yes?).and_return true
          end

          it "sends an email" do
            expect {
              form.take_action
            }.to change(OutgoingEmail, :count).by(0)
          end

          it "does not send a text" do
            expect {
              form.take_action
            }.to change(OutgoingTextMessage, :count).by(1)
          end
        end

        it "does not create a note" do
          expect {
            form.take_action
          }.not_to change(Note, :count)
        end

        it "creates an action list" do
          form.take_action
          expect(form.action_list).to eq ["updated status", "sent email"]
        end
      end

      context "status change with note" do
        let(:internal_note_body) { "hi" }
        let(:form) { Hub::TakeActionForm.new(client, current_user, { tax_return_id: tax_return.id, internal_note_body: internal_note_body, message_body: "", status: "intake_more_info" }) }
        it "creates an action list" do
          form.take_action
          expect(form.action_list).to eq ["updated status", "added internal note"]
        end

        it "creates a note" do
          expect {
            form.take_action
          }.to change(Note, :count).by(1)

          note = Note.last
          expect(note.user).to eq current_user
          expect(note.body).to eq internal_note_body
          expect(note.client).to eq client
        end
      end

      context "status change with provided but empty note / message" do
        let(:internal_note_body) { " \n" }
        let(:message_body) { " \n" }

        let(:form) { Hub::TakeActionForm.new(client, current_user, { tax_return_id: tax_return.id, internal_note_body: internal_note_body, message_body: "", status: "intake_more_info" }) }

        it "does not save a note" do
          expect do
            form.take_action
          end.not_to change(Note, :count)
        end

        it "does not send a message" do
          expect do
            form.take_action
          end.not_to change(OutgoingEmail, :count)
        end

        it "does not save a message" do
          expect do
            form.take_action
          end.not_to change(OutgoingTextMessage, :count)
        end
      end
    end
  end
end
