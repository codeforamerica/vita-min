require "rails_helper"

RSpec.describe Questions::NotificationPreferenceController do
  render_views

  let(:zendesk_requester_id) { nil }
  let(:zendesk_ticket_id) { nil }
  let(:intake) { create :intake, intake_ticket_id: zendesk_ticket_id, intake_ticket_requester_id: zendesk_requester_id }
  let(:user) { create :user, intake: intake }
  let(:fake_zendesk_intake_service) { double(ZendeskIntakeService) }

  before do
    allow(subject).to receive(:current_user).and_return(user)
    allow(subject).to receive(:send_mixpanel_event)
    allow(ZendeskIntakeService).to receive(:new).with(intake).and_return(fake_zendesk_intake_service)
    allow(fake_zendesk_intake_service).to receive(:create_intake_ticket_requester).and_return(23)
    allow(fake_zendesk_intake_service).to receive(:create_intake_ticket).and_return(5)
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          notification_preference_form: {
            email_notification_opt_in: "yes",
            sms_notification_opt_in: "no",
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

      context "making a new Zendesk ticket" do
        before { post :update, params: params }

        context "without a requester or ticket" do
          let(:zendesk_requester_id) { nil }
          let(:zendesk_ticket_id) { nil }

          it "creates a new intake ticket in Zendesk and saves IDs to the intake" do
            intake.reload
            expect(ZendeskIntakeService).to have_received(:new).with(intake)
            expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket_requester).with(no_args)
            expect(intake.intake_ticket_requester_id).to eq 23
            expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket).with(no_args)
            expect(intake.intake_ticket_id).to eq 5
          end
        end

        context "with a requester but no ticket" do
          let(:zendesk_requester_id) { 32 }
          let(:zendesk_ticket_id) { nil }

          it "only creates a ticket" do
            intake.reload
            expect(ZendeskIntakeService).to have_received(:new).with(intake)
            expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket_requester)
            expect(intake.intake_ticket_requester_id).to eq 32
            expect(fake_zendesk_intake_service).to have_received(:create_intake_ticket).with(no_args)
            expect(intake.intake_ticket_id).to eq 5
          end
        end

        context "with a requester and ticket" do
          let(:zendesk_requester_id) { 32 }
          let(:zendesk_ticket_id) { 7 }

          it "does not call the zendesk service" do
            intake.reload
            expect(ZendeskIntakeService).not_to have_received(:new)
            expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket_requester)
            expect(intake.intake_ticket_requester_id).to eq 32
            expect(fake_zendesk_intake_service).not_to have_received(:create_intake_ticket)
            expect(intake.intake_ticket_id).to eq 7
          end
        end
      end
    end
  end
end
