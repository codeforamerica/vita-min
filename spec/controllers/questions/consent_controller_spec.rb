require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:intake) { create :intake, :unconsented, preferred_name: "Ruthie Rutabaga", email_address: "hi@example.com", sms_phone_number: "+18324651180", source: "SourceParam", zip_code: "80309", needs_help_2021: "yes", needs_help_2020: "yes" }
  let(:client) { intake.client}
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
          }
        }
      end
      let(:ip_address) { "127.0.0.1" }

      before do
        session[:intake_id] = intake.id
        request.remote_ip = ip_address
        allow(MixpanelService).to receive(:send_event)
      end

      it "saves the answer, along with a timestamp and ip address and consent fields" do
        post :update, params: params

        intake.reload
        expect(intake.primary_consented_to_service_ip).to eq ip_address
        expect(intake.primary_consented_to_service_at).not_to eq nil
        expect(intake.primary_consented_to_service).to eq "yes"
      end

      it "authenticates the client and clears the intake_id from the session" do
        expect do
          expect do
            post :update, params: params
          end.to change { session[:intake_id] }.to(nil)
        end.to change { subject.current_client }.from(nil).to(intake.client)
      end

      context "creating tax returns" do
        it "creates tax returns in the intake in progress status for years indicated as needing help" do
          post :update, params: params

          expect(intake.tax_returns.pluck(:status).uniq).to eq ["intake_in_progress"]
          expect(intake.tax_returns.count).to eq 2
          expect(intake.tax_returns.pluck(:year)).to match_array([2021, 2020])
        end

        context "when a tax return for a selected year already exists" do
          let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client, year: 2018 }
          before do
            intake.update(needs_help_2018: "yes")
          end

          it "uses the existing tax return object and does not crash" do
            post :update, params: params

            expect(intake.tax_returns.count).to eq 3
            expect(intake.tax_returns.pluck(:year)).to match_array([2018, 2021, 2020])
            expect(intake.tax_returns.find_by(year: 2018)).to eq tax_return
          end
        end

        context "when a tax return had existed for a specific year but the needs_help_xxxx value is now false" do
          let!(:tax_return) { create :tax_return, :intake_in_progress, client: intake.client, year: 2021 }

          before do
            intake.update(needs_help_2021: "no")
          end

          it "does not have that tax return associated anymore" do
            expect(intake.tax_returns.pluck(:year)).to include 2021

            post :update, params: params
            expect(intake.tax_returns.pluck(:year)).not_to include 2021
          end
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

      context "routing the client" do
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

          context "when routing service returns nil and routing_method is at_capacity" do
            before do
              allow(organization_router).to receive(:determine_partner).and_return nil
              allow(organization_router).to receive(:routing_method).and_return :at_capacity
            end

            it "saves routing method to at capacity, does not set a vita partner, does not create tax returns" do
              post :update, params: params

              intake.reload
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
              expect(intake.tax_returns.count).to eq 0
              expect(response).to redirect_to Questions::AtCapacityController.to_path_helper
            end
          end
        end

        context "when a client has already been routed as at capacity" do
          let(:client) { create :client, routing_method: "at_capacity" }
          let(:intake) { create :intake, client: client }

          it "runs routing on them again" do
            post :update, params: params

            expect(organization_router).to have_received(:determine_partner)
          end
        end

        context "when a client has already been routed (routing_method is present)" do
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
          }
        }
      end

      it "renders edit with a validation error message" do
        post :update, params: params

        expect(response).to render_template :edit
        error_messages = assigns(:form).errors.messages
        expect(error_messages[:primary_last_name].first).to eq "Please enter your last name."
      end
    end

    context "with an itin applicant that has a duplicate" do
      before do
        allow(intake).to receive(:has_duplicate?).and_return true
        allow(intake).to receive(:itin_applicant?).and_return true
      end
      let(:params) do
        {
            consent_form: {
                birth_date_year: "1983",
                birth_date_month: "5",
                birth_date_day: "10",
                primary_first_name: "Greta",
                primary_last_name: "Gnome",
            }
        }
      end

      it "redirects to returning_clients page without saving as consented" do
        post :update, params: params

        expect(response).to redirect_to returning_client_questions_path
        expect(intake.primary_consented_to_service_at).to be_nil
        expect(intake)
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
          allow_any_instance_of(Client).to receive(:routing_method_at_capacity?).and_return true
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
        it "sends the 'getting started' message in english" do
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

        it "sends the 'getting started' message in spanish" do
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
