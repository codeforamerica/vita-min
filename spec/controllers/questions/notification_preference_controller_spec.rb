require "rails_helper"

RSpec.describe Questions::NotificationPreferenceController do
  render_views

  let(:user) { create(:user) }
  let(:intake) { user.intake }

  before do
    allow(subject).to receive(:current_user).and_return(user)
    allow(subject).to receive(:send_mixpanel_event)
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
    end
  end
end
