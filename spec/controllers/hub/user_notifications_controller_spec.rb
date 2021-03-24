require "rails_helper"

RSpec.describe Hub::UserNotificationsController, type: :controller do
  let(:user) { create :team_member_user }
  let!(:notification_first) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
  let!(:notification_second) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
  let!(:notification_third) { create :user_notification, user: user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }
  let!(:other_notification) { create :user_notification, user: create(:user), read: false, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as a logged in user loading user notifications" do

      before { sign_in user }

      it "loads notifications in descending order" do
        get :index

        expect(response).to be_ok
        expect(assigns(:user_notifications)).not_to include other_notification
        expect(assigns(:user_notifications)).to eq [notification_third, notification_second, notification_first]
      end
    end
  end

  describe "#mark_all_notifications_read" do
    it_behaves_like :a_post_action_for_authenticated_users_only, action: :mark_all_notifications_read

    context "as an authenticated hub user" do
      before { sign_in user }

      it "marks all the notifications as read" do
        post :mark_all_notifications_read

        expect(response.status).to eq 302
        expect(notification_first.reload.read).to eq true
        expect(notification_second.reload.read).to eq true
        expect(other_notification.reload.read).to eq false
        expect(response).to redirect_to hub_user_notifications_path
      end
    end
  end
end
