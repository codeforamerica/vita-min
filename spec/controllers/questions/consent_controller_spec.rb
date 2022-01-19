require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:intake) { create :intake, client: nil, preferred_name: "Ruthie Rutabaga", email_address: "hi@example.com", sms_phone_number: "+18324651180", source: "SourceParam", zip_code: "80309", needs_help_2021: "yes", needs_help_2020: "yes" }
  let!(:routing_double) { double(routing_method: "zip_code", determine_partner: (create :organization) ) }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(PartnerRoutingService).to receive(:new).and_return(routing_double)
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
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

      it "creates tax returns in the intake in progress status for years indicated as needing help" do
        post :update, params: params

        expect(intake.tax_returns.pluck(:status).uniq).to eq ["intake_in_progress"]
        expect(intake.tax_returns.count).to eq 2
        expect(intake.tax_returns.pluck(:year)).to eq [2021, 2020]
      end

      context "when there is no client in the session" do
        it "creates a client" do
          expect {
            post :update, params: params
          }.to change(Client, :count).by(1)

          client = Client.last
          expect(client.intake).to eq intake
        end

        it "authenticates the client and clears the intake_id from the session" do
          expect(subject.current_client).to be_nil

          post :update, params: params

          expect(subject.current_client).to eq intake.client
          expect(session[:intake_id]).to be_nil
        end
      end

      context "when there is a client in the session" do
        let(:client) { create :client, intake: intake }

        before do
          allow(subject).to receive(:current_intake).and_return(nil)
          allow(subject).to receive(:current_client).and_return client
        end

        it "does not create a new client" do
          expect {
            post :update, params: params
          }.not_to change(Client, :count)

          expect(subject.current_client).to eq client
        end
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

      context "routing the client in after update callback" do
        let(:organization_router) { double }
        let(:organization) { create :organization }

        before do
          allow(PartnerRoutingService).to receive(:new).and_return organization_router
          allow(organization_router).to receive(:determine_partner).and_return organization
          allow(organization_router).to receive(:routing_method).and_return :source_param
        end

        context "when a client has not yet been routed (routing_method is not present)" do
          it "gets routed" do
            post :update, params: params

            expect(PartnerRoutingService).to have_received(:new).with(
                {
                  intake: intake,
                  source_param: "SourceParam",
                  zip_code: "80309"
                }
            )
            expect(organization_router).to have_received(:determine_partner)
          end

          it "updates the intake and the client with the routed organization" do
            post :update, params: params
            intake.reload

            expect(intake.client.vita_partner_id).to eq organization.id
            expect(intake.client.routing_method).to eq "source_param"
            expect(response).to redirect_to optional_consent_questions_path

          end

          context "when routing service returns nil" do
            before do
              allow(organization_router).to receive(:determine_partner).and_return nil
              allow(organization_router).to receive(:routing_method).and_return :at_capacity
            end

            it "saves routing method to at capacity, but does not set a vita partner" do
              post :update, params: params

              expect(intake.client.routing_method).to eq("at_capacity")

              expect(intake.client.vita_partner).to eq nil

              expect(PartnerRoutingService).to have_received(:new).with(
                  {
                      intake: intake,
                      source_param: "SourceParam",
                      zip_code: "80309"
                  }
              )
              expect(organization_router).to have_received(:determine_partner)
              expect(response).to redirect_to optional_consent_questions_path
            end
          end
        end

        context "when a client has already been routed (routing_method is nil)" do
          let(:client) { create :client, routing_method: "returning_client" }
          let(:intake) { create :intake, client: client }

          it "does not route again" do
            post :update, params: params

            expect(organization_router).not_to have_received(:determine_partner)
          end
        end
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

      context "when routing method is set to at capacity on the client" do
        before do
          intake.create_client(routing_method: "at_capacity")
        end

        it "does not send a message" do
          subject.after_update_success

          expect(ClientMessagingService).not_to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
              client: intake.client,
              message: AutomatedMessage::GettingStarted,
              locale: :en
          )
        end
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
