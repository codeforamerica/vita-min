require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:eip_only) { false }
  let(:intake) { create :intake, eip_only: eip_only }
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

      context "for full intake ticket job", active_job: true do
        it "enqueues a job to make an zendesk intake ticket" do
          post :update, params: params

          expect(CreateZendeskIntakeTicketJob).to have_been_enqueued
          expect(CreateZendeskEipIntakeTicketJob).not_to have_been_enqueued
        end
      end

      context "for EIP-only Intake ticket", active_job: true do
        let(:eip_only) { true }

        it "enqueues a job to make an EIP Zendesk ticket" do
          post :update, params: params
          expect(CreateZendeskEipIntakeTicketJob).to have_been_enqueued
          expect(CreateZendeskIntakeTicketJob).not_to have_been_enqueued
        end
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
end
