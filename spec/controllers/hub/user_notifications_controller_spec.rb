require "rails_helper"

RSpec.describe Hub::UserNotificationsController, type: :controller do
  let(:user) { create :user, role: create(:team_member_role) }
  describe "#index" do
    let(:day_one) { DateTime.new(2021, 3, 11, 8, 1).utc }
    let(:day_two) { DateTime.new(2021, 3, 12, 8, 1).utc }
    let(:day_three) { DateTime.new(2021, 3, 13, 8, 1).utc }
    let!(:notification_first) { create :user_notification, user: user, read: false, created_at: day_one }
    let!(:notification_second) { create :user_notification, user: user, read: false, created_at: day_two }
    let!(:notification_third) { create :user_notification, user: user, read: false, created_at: day_three }

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
end
