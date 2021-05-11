require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:intake) { create :intake, preferred_name: "Ruthie Rutabaga", email_address: "hi@example.com", sms_phone_number: "+18324651180" }
  let(:client) { intake.client }
  let!(:tax_return) { create :tax_return, client: client }

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

      it "authenticates the client and clears the intake_id from the session" do
        expect do
          post :update, params: params
        end.to change{ subject.current_client }.from(nil).to(client)

        expect(session[:intake_id]).to be_nil
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

          expect(ClientMessagingService).to have_received(:send_system_email).with(
            client: intake.client,
            body: I18n.t("messages.getting_started.email_body", locale: "en"),
            subject: "Getting your taxes started with GetYourRefund",
          )
        end

        it "sends the text in english" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
            client: intake.client,
            body: I18n.t("messages.getting_started.sms_body", locale: "en")
          )
        end
      end

      context "when the locale is es" do
        around do |example|
          I18n.with_locale(:es) { example.run }
        end

        it "sends the email in spanish" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_email).with(
              client: intake.client,
              body: I18n.t("messages.getting_started.email_body", locale: "es"),
              subject: "Comience a tramitar sus impuestos con GetYourRefund",
              )
        end

        it "sends the text in spanish" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_text_message).with(
              client: intake.client,
              body: I18n.t("messages.getting_started.sms_body", locale: "es"),
              )
        end
      end
    end
  end
end
