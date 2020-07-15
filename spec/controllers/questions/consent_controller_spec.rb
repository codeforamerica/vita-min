require "rails_helper"

RSpec.describe Questions::ConsentController do
  let(:zendesk_ticket_id) { nil }
  let(:intake) { create :intake, intake_ticket_id: zendesk_ticket_id }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
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
            primary_last_four_ssn: "5678"
          }
        }
      end
      let(:ip_address) { "127.0.0.1" }

      before do
        request.remote_ip = ip_address
      end

      it "saves the answer, along with a timestamp and ip address" do
        post :update, params: params

        intake.reload
        expect(intake.primary_consented_to_service_ip).to eq ip_address
      end

      context "making a new Zendesk ticket", active_job: true do
        before { post :update, params: params }

        context "without a ticket id" do
          let(:zendesk_ticket_id) { nil }

          it "enqueues a job to make a zendesk ticket" do
            expect(CreateZendeskIntakeTicketJob).to have_been_enqueued
          end
        end

        context "with a ticket id" do
          let(:zendesk_ticket_id) { 32 }

          it "does not enqueue a job to make a zendesk ticket" do
            expect(CreateZendeskIntakeTicketJob).not_to have_been_enqueued
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
