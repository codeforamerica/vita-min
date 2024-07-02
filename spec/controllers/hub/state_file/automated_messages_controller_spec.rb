require "rails_helper"

describe Hub::StateFile::AutomatedMessagesController do
  describe "#index" do
    it_behaves_like :a_get_action_for_admins_only, action: :index

    context "as an authenticated user" do
      before { sign_in create(:state_file_admin_user) }
      render_views

      it "successfully renders messages that are sent to client in an automated way" do
        get :index
        expected_text = StateFile::AutomatedMessage::AcceptedRefund.new.sms_body(
          primary_first_name: "Cornelius",
          state_name: "Arizona",
          return_status_link: SendRejectResolutionReminderNotificationJob.return_status_link(
            :az, :en
          ),
        )
        expect(response.body).to have_text(expected_text)
      end
    end
  end
end
