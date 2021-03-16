require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:intake) { create :intake, preferred_name: "Ruthie Rutabaga" }
  let!(:tax_return) { create :tax_return, client: intake.client }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    context "with valid params" do
      let (:params) do
        {
          consent_form: {
            birth_date_year: "1983",
            birth_date_month: "5",
            birth_date_day: "10",
            primary_first_name: "Greta",
            primary_last_name: "Gnome",
            primary_last_four_ssn: "5678"
          }
        }
      end
      let(:ip_address) { "127.0.0.1" }

      before do
        request.remote_ip = ip_address
        allow(MixpanelService).to receive(:send_event)
      end

      it "saves the answer, along with a timestamp and ip address" do
        post :update, params: params

        intake.reload
        expect(intake.primary_consented_to_service_ip).to eq ip_address
      end

      it "updates all tax return statuses to 'In Progress'" do
        post :update, params: params

        expect(tax_return.reload.status).to eq "intake_in_progress"
      end

      it "sends an event to mixpanel without PII" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "question_answered",
          data: hash_excluding(
            :primary_first_name,
            :primary_last_name,
            :primary_last_four_ssn
          )
        ))
      end
    end

    context "with invalid params" do
      let (:params) do
        {
          consent_form: {
            birth_date_year: "1983",
            birth_date_month: nil,
            birth_date_day: "10",
            primary_first_name: "Grindelwald",
            primary_last_name: nil,
            primary_last_four_ssn: nil
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:primary_last_four_ssn].first).to eq "Please enter the last four digits of your SSN or ITIN."
        expect(error_messages[:primary_last_name].first).to eq "Please enter your last name."
      end
    end
  end

  describe "#after_update_success" do
    before do
      allow(ClientMessagingService).to receive(:send_system_email)
      allow(ClientMessagingService).to receive(:send_system_text_message)
    end

    it "enqueues a job to generate the consent form and the intake form" do
      expect(Intake14446PdfJob).to receive(:perform_later).with(intake, "Consent Form 14446.pdf")
      expect(IntakePdfJob).to receive(:perform_later).with(intake.id, "Preliminary 13614-C.pdf")

      subject.after_update_success
    end

    context "notification preferences" do
      context "when the client has opted in to just email" do
        before do
          intake.update(email_notification_opt_in: "yes")
        end

        it "sends them a confirmation email but not a text" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_email)
          expect(ClientMessagingService).not_to have_received(:send_system_text_message)
        end
      end

      context "when the client has opted in to just sms" do
        before do
          intake.update(sms_notification_opt_in: "yes")
        end

        it "sends them a text but not an email" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_text_message)
          expect(ClientMessagingService).not_to have_received(:send_system_email)
        end
      end

      context "when the client has opted in to both email and sms" do
        before do
          intake.update(sms_notification_opt_in: "yes")
          intake.update(email_notification_opt_in: "yes")
        end

        it "sends them a text and an email" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_text_message)
          expect(ClientMessagingService).to have_received(:send_system_email)
        end
      end
    end

    context "content translation" do
      before do
        intake.update(email_notification_opt_in: "yes")
        intake.update(sms_notification_opt_in: "yes")
      end

      context "when the intake locale is en" do
        before do
          intake.update(locale: "en")
        end

        it "sends the email in english" do
          subject.after_update_success

          email_body = <<~BODY
            Hello Ruthie Rutabaga,

            Thanks for starting your taxes with GetYourRefund - you’re almost there! Your client id is #{intake.client_id}. We will prepare your taxes once we have all of your required information and tax documents.

            You can securely upload your ID and additional tax documents here: #{intake.requested_docs_token_link}

            If you have any questions you can contact your tax team via email <a href="mailto:hello@getyourrefund.org>hello@getyourrefund.org</a> or text message 58750.

            Remember, we’ll review everything with you before filing so just do the best you can. Then we’ll help you get the tax credits that belong to you!

            We’re here to help!
            Your Tax Team at GetYourRefund.org
          BODY

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            intake.client,
            email_body,
            "Getting your taxes started with GetYourRefund",
          )
        end

        it "sends the text in english" do
          subject.after_update_success

          body = <<~BODY
            Hello Ruthie Rutabaga, thanks for starting your taxes with GetYourRefund, you’re almost there! Your client id is #{intake.client_id}. We won’t be able to prepare your taxes until we have all of your required information and tax documents. Upload documents securely here: #{intake.requested_docs_token_link}

            Respond to this message if you have any questions. We’re here to help!

          BODY

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            intake.client,
            body.chomp,
          )
        end
      end

      context "when the intake locale is es" do
        before do
          intake.update(locale: "es")
        end

        it "sends the email in spanish" do
          subject.after_update_success

          email_body = <<~BODY
            Hola Ruthie Rutabaga,

            Gracias por comenzar el trámite de sus impuestos con GetYourRefund - ¡ya le falta poco! Su cliente id es #{intake.client_id}. Empezaremos a preparar sus impuestos una vez que recibamos toda la información requerida y los documentos de sus impuestos.

            Puede subir su identificación o documentos de impuestos adicionales a su enlace de envío seguro aquí: #{intake.requested_docs_token_link}

            Si tiene alguna pregunta puede contactar a su equipo de preparación de impuestos por correo electrónico a <a href="mailto:hello@getyourrefund.org"></a>, o enviar un mensaje de texto al 58750.

            Recuerde, nosotros revisaremos todo con usted antes de presentar sus documentos, así que procure hacer lo mejor posible. ¡Así le ayudaremos a conseguir los créditos fiscales que le pertenecen!

            ¡Estamos aquí para servirle!

            Su Equipo de Impuestos de GetYourRefund.org
          BODY

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            intake.client,
            email_body,
            "Comience a tramitar sus impuestos con GetYourRefund",
          )
        end

        it "sends the text in spanish" do
          subject.after_update_success

          body = <<~BODY
            Hola Ruthie Rutabaga, gracias por comenzar su declaración de impuestos con GetYourRefund !ya le falta poco! Su cliente id es #{intake.client_id}. No podremos preparar sus impuestos hasta que tengamos toda la información requerida y los documentos de impuestos. Suba sus documentos a su enlace de envío seguro aquí: #{intake.requested_docs_token_link}
            Responda a este mensaje con cualquier pregunta. ¡Estamos aquí para servirle!

          BODY

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            intake.client,
            body.chomp,
          )
        end
      end
    end
  end
end
