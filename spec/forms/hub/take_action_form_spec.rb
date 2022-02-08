require "rails_helper"

RSpec.describe Hub::TakeActionForm do
  let(:client) { intake.client }
  let(:current_user) { create :admin_user, name: "Marilyn Mango" }
  let(:intake) { create :intake, email_address: "example@example.com" }
  let(:tax_return) { create :tax_return, client: client, year: 2019 }
  let(:form) { Hub::TakeActionForm.new(client, current_user, form_params) }

  describe "validations" do
    context "when tax_return_id is not part of clients tax returns" do
      let(:form_params) {{ tax_return_id: create(:tax_return).id }}

      it "add an error to the object" do
        expect(form).not_to be_valid
        expect(form.errors[:tax_return_id]).to include "Can't update tax return unrelated to current client."
      end
    end

    context "when new status is same as current status" do
      let(:form_params) {{ state: tax_return.status, tax_return_id: tax_return.id }}

      it "add an error to the object" do
        expect(form).not_to be_valid
        expect(form.errors[:state]).to include "Can't initiate status change to current status."
      end
    end

    context "when the status is blank" do
      let(:form_params) {{ tax_return_id: tax_return.id, state: " \n" }}

      it "add an error to the object" do
        expect(form).not_to be_valid
        expect(form.errors[:state]).to include "Can't be blank."
      end
    end

    context "when REPLACE ME is included in the message body" do
      let(:form_params) {{ tax_return_id: tax_return.id, message_body: "REPLACE ME" }}
      it "add an error to the object" do
        expect(form).not_to be_valid
        expect(form.errors[:message_body]).to include "Replace REPLACE ME with relevant information before proceeding."
      end
    end
  end

  describe "setting default values" do
    let(:intake) { create :intake, locale: "es", preferred_name: "Luna Lemon", email_address: "example@example.com" }
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
        let(:form) { Hub::TakeActionForm.new(client, current_user,{ message_body: "hi", state: "intake_needs_info" }) }
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
        let(:form) { Hub::TakeActionForm.new(client, current_user, { state: "intake_info_requested", locale: "en" }) }
        before do
          allow(intake).to receive(:email_notification_opt_in_yes?).and_return true
          allow(intake).to receive(:sms_notification_opt_in_yes?).and_return true
        end

        it "sets message body to the template with replacement parameters substituted" do
          expect(form.message_body).to start_with("Hello")
          expect(form.message_body).to include client.preferred_name
          expect(form.message_body).to include current_user.first_name
        end

        context "when the user has no contact methods" do
          let(:form) { Hub::TakeActionForm.new(client, current_user, { state: "intake_info_requested", locale: "en" }) }
          before do
            allow(intake).to receive(:email_notification_opt_in_yes?).and_return false
            allow(intake).to receive(:sms_notification_opt_in_yes?).and_return false
          end
          it "does not set a message body" do
            expect(form.message_body).to eq ""
          end
        end
      end

      context "when a status that has a message template is provided and locale is spanish" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { state: "intake_info_requested", locale: "es" }) }
        let(:filled_out_template) {
          <<~MESSAGE
            ¡Hola Luna Lemon!

            Para continuar presentando sus impuestos, necesitamos que nos envíe:
              - Identificación con foto
              - Foto de usted sosteniendo su identificación con la foto cerca de su barbilla
              - Foto de la tarjeta SSN o del documento ITIN para usted, su cónyuge y sus dependientes
            Inicie sesión para cargar los documentos de forma segura: http://test.host/es/portal/login

            Por favor, háganos saber si usted tiene alguna pregunta. No podemos preparar sus impuestos sin esta información.

            ¡Gracias!
            Marilyn en GetYourRefund.org
          MESSAGE
        }

        before do
          allow(client.intake).to receive(:relevant_document_types).and_return [DocumentTypes::Identity, DocumentTypes::Selfie, DocumentTypes::SsnItin, DocumentTypes::Other]
          allow(intake).to receive(:email_notification_opt_in_yes?).and_return true
          allow(intake).to receive(:sms_notification_opt_in_yes?).and_return true
        end

        it "sets message body to the template with replacement parameters substituted" do
          expect(form.message_body).to eq filled_out_template
          expect(form.message_body).to include client.preferred_name
          expect(form.message_body).to include current_user.first_name
        end
      end

      context "when a status without a message template is provided" do
        let(:form) { Hub::TakeActionForm.new(client, current_user, { state: "non_matching_status"})}
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
        let(:form) { Hub::TakeActionForm.new(client, current_user) }

        context "when user prefers sms" do
          before do
            allow(client.intake).to receive(:sms_notification_opt_in_yes?).and_return true
            allow(client.intake).to receive(:email_notification_opt_in_no?).and_return true
          end

          it "sets to sms" do
            expect(form.contact_method).to eq "text_message"
          end
        end

        context "when user does not only prefer sms" do
          before do
            allow(client.intake).to receive(:sms_notification_opt_in_yes?).and_return true
            allow(client.intake).to receive(:email_notification_opt_in_no?).and_return false
          end

          it "sets to email" do
            expect(form.contact_method).to eq "email"
          end
        end

        context "when user prefers email but their email address is blank" do
          before do
            client.intake.update!(email_notification_opt_in: "yes", email_address: "")
          end

          it "is nil" do
            expect(form.contact_method).to eq nil
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
      let(:intake) { create :intake, email_notification_opt_in: "yes", email_address: "example@example.com" }

      it "shows only email as a contact option" do
        expect(form.contact_method_options).to eq([{value: "email", label: "Email message"}])
      end
    end

    context "with a client opted-in to both email and text message" do
      let(:intake) { create :intake, email_notification_opt_in: "yes", email_address: "example@example.com", sms_notification_opt_in: "yes" }

      it "shows only text message as a contact option" do
        expect(form.contact_method_options).to eq([{value: "email", label: "Email message"}, {value: "text_message", label: "Text message"}])
      end
    end

    context "with a client opted-in to email but with a blank email address" do
      let(:intake) { create :intake, email_notification_opt_in: "yes", email_address: "" }

      it "does not show email address as a contact option" do
        expect(form.contact_method_options).not_to include({ value: "email", label: "Email message" })
      end
    end

    context "with a client that hasn't opted into anything" do
      let(:intake) { create :intake }

      it "returns no contact options" do
        expect(form.contact_method_options).to eq([])
      end
    end
  end
end
