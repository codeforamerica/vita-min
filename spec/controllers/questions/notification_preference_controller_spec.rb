require "rails_helper"

RSpec.describe Questions::NotificationPreferenceController do
  render_views

  let(:zendesk_ticket_id) { nil }
  let(:intake) { create :intake, intake_ticket_id: zendesk_ticket_id }
  let(:user) { create :user, intake: intake }

  before do
    allow(subject).to receive(:current_user).and_return(user)
    allow(subject).to receive(:current_intake).and_return(intake)
    allow(subject).to receive(:send_mixpanel_event)
  end

  describe "#edit" do
    let!(:intake) { create :intake, phone_number: "15552223333", phone_number_can_receive_texts: "yes" }

    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end

    it "pre-populates the cell phone field if they said they can receive texts" do
      get :edit

      expect(response.body).to include("15552223333")
    end
  end

  describe "#update" do
    context "with invalid params" do
      let(:params) do
        {
          notification_preference_form: {
            sms_notification_opt_in: "yes",
            sms_phone_number: nil,
          }
        }
      end

      it "renders an error for the user" do
        post :update, params: params

        user.reload
        expect(user.sms_notification_opt_in).to eq("unfilled")
        expect(response.body).to include("Please enter a cell phone number.")
        expect(response).not_to be_redirect
      end
    end

    context "with valid params" do
      let(:params) do
        {
          notification_preference_form: {
            email_notification_opt_in: "yes",
            sms_notification_opt_in: "no",
            sms_phone_number: "555-333-4444"
          }
        }
      end

      it "updates the user's notification preferences" do
        expect(user.sms_notification_opt_in).to eq("unfilled")
        expect(user.email_notification_opt_in).to eq("unfilled")

        post :update, params: params

        user.reload
        expect(user.sms_notification_opt_in).to eq("no")
        expect(user.email_notification_opt_in).to eq("yes")
        expect(intake.sms_phone_number).to eq("15553334444")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params

        expect(subject).to have_received(:send_mixpanel_event).with(
          event_name: "question_answered",
          data: {
            email_notification_opt_in: "yes",
            sms_notification_opt_in: "no",
          }
        )
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
  end
end
