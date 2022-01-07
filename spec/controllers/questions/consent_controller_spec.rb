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
            primary_ssn: "123455678",
            primary_ssn_confirmation: "123455678",
            primary_tin_type: "ssn_no_employment"
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
            :primary_ssn
          )
        ))
      end

      it "authenticates the client and clears the intake_id from the session" do
        expect do
          post :update, params: params
        end.to change { subject.current_client }.from(nil).to(client)

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
            primary_ssn: nil
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:primary_ssn].first).to eq "An SSN or ITIN is required."
        expect(error_messages[:primary_tin_type].first).to eq "Identification type is required."
        expect(error_messages[:primary_last_name].first).to eq "Please enter your last name."
      end
    end
  end

  describe "#after_update_success" do
    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      allow(GenerateRequiredConsentPdfJob).to receive(:perform_later)
      allow(GenerateF13614cPdfJob).to receive(:perform_later)
    end

    it "enqueues a job to generate the consent form and the intake form" do
      subject.after_update_success

      expect(GenerateRequiredConsentPdfJob).to have_received(:perform_later).with(intake)
      expect(GenerateF13614cPdfJob).to have_received(:perform_later).with(intake.id, "Preliminary 13614-C.pdf")
    end

    context "messaging" do
      before do
        intake.update(email_notification_opt_in: "yes")
        intake.update(sms_notification_opt_in: "yes")
      end

      context "when the intake locale is en" do
        it "sends with english translations" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: intake.client,
            message: AutomatedMessage::GettingStarted,
            locale: :en
          )
        end
      end

      context "when the locale is es" do
        around do |example|
          I18n.with_locale(:es) { example.run }
        end

        it "sends the email in spanish" do
          subject.after_update_success

          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: intake.client,
            message: AutomatedMessage::GettingStarted,
            locale: :es
          )
        end
      end
    end
  end
end
