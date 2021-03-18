require "rails_helper"

RSpec.describe Hub::UserNotificationsController, type: :controller do
  let(:user) { create :user, role: create(:team_member_role) }
  let!(:notification_first) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
  let!(:notification_second) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
  let!(:notification_third) { create :user_notification, user: user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }

  describe "#index" do
    context "as a logged in user loading user notifications" do
      render_views

      before do
        sign_in user
      end

      it "loads notifications in descending order" do
        get :index

        expect(response).to be_ok

        expect(assigns(:user_notifications)).to eq [notification_third, notification_second, notification_first]
      end
    end
  end

  describe "#mark_all_notifications_read" do
    let!(:notification_other) { create :user_notification, user: create(:user), read: false }

    before do
      controller.instance_variable_set(:@user_notifications, UserNotification.where(user: user))
    end

    context "when there are notifications that have not been read" do
      it "marks all the notifications as read" do
        controller.mark_all_notifications_read
        expect(notification_first.reload.read).to eq true
        expect(notification_second.reload.read).to eq true
        expect(notification_other.reload.read).to eq false
      end
    end
  end
end
