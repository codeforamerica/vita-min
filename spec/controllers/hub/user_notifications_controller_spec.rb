require "rails_helper"

RSpec.describe Hub::UserNotificationsController, type: :controller do
  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "as a logged in user loading user notifications" do
      let(:team_member_user) { create :user, role: create(:team_member_role) }
      let(:site_coordinator_user) { create :user, role: create(:site_coordinator_role) }
      let(:admin_user) { create :user, role: create(:admin_role) }

      let!(:team_member_notification_first) { create :user_notification, user: team_member_user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
      let!(:team_member_notification_second) { create :user_notification, user: team_member_user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
      let!(:team_member_notification_third) { create :user_notification, user: team_member_user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }

      let!(:site_coordinator_notification_first) { create :user_notification, user: site_coordinator_user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
      let!(:site_coordinator_notification_second) { create :user_notification, user: site_coordinator_user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
      let!(:site_coordinator_notification_third) { create :user_notification, user: site_coordinator_user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }

      let!(:admin_notification_first) { create :user_notification, user: admin_user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
      let!(:admin_notification_second) { create :user_notification, user: admin_user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
      let!(:admin_notification_third) { create :user_notification, user: admin_user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }
      let!(:other_admin_notification) { create :user_notification, user: (create :admin_user), read: false, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }

      render_views

      context "team member user" do
        before { sign_in team_member_user }

        it "loads notifications in descending order" do
          get :index

          expect(response).to be_ok

          expect(assigns(:user_notifications)).to eq [team_member_notification_third, team_member_notification_second, team_member_notification_first]
        end
      end

      context "site coordinator user" do
        before { sign_in site_coordinator_user }

        it "loads notifications in descending order" do
          get :index

          expect(response).to be_ok

          expect(assigns(:user_notifications)).to eq [site_coordinator_notification_third, site_coordinator_notification_second, site_coordinator_notification_first]
        end
      end

      context "as an admin" do
        before { sign_in admin_user }

        it "loads notifications in descending order" do
          get :index

          expect(response).to be_ok
          expect(assigns(:user_notifications)).not_to include other_admin_notification

          expect(assigns(:user_notifications)).to eq [admin_notification_third, admin_notification_second, admin_notification_first]

        end
      end
    end
  end

  describe "#mark_all_notifications_read" do
    let(:user) { create :user, role: create(:team_member_role) }
    let!(:notification_first) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 11, 8, 1).utc }
    let!(:notification_second) { create :user_notification, user: user, read: false, created_at: DateTime.new(2021, 3, 12, 8, 1).utc }
    let!(:notification_read) { create :user_notification, user: user, read: true, created_at: DateTime.new(2021, 3, 13, 8, 1).utc }
    let!(:notification_other) { create :user_notification, user: create(:user), read: false }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :mark_all_notifications_read

    context "as an authenticated hub user" do
      before { sign_in user }

      it "marks all the notifications as read" do
        post :mark_all_notifications_read

        expect(response.status).to eq 302
        expect(notification_first.reload.read).to eq true
        expect(notification_second.reload.read).to eq true
        expect(notification_other.reload.read).to eq false
        expect(response).to redirect_to hub_user_notifications_path
      end
    end
  end
end
