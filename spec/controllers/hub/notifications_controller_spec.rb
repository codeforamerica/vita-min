require "rails_helper"

RSpec.describe Hub::NotificationsController, type: :controller do
  describe "#index" do
    # xcontext "when user is tagged" do
    #   it "sends notification" do
    #
    #   end
    # end

    context "when user is assigned to client" do
      it "sends notification" do

      end
    end

    # xcontext "when user does a bulk edit" do
    #   it "sends notification" do
    #
    #   end
    # end

    # when assignment changes it creates a notification
    # when view this page it changes records to read
    # make test for model
  end

  describe "#group_notifications" do
    let(:user) { create :user, role: create(:organization_lead_role, organization: create(:organization)) }
    let(:day_one) { DateTime.new(2021, 3, 11, 8, 1).utc }
    let(:day_two) { DateTime.new(2021, 3, 12, 8, 1).utc }
    let!(:notification_day_one_first) { create :user_notification, user: user, created_at: day_one }
    let!(:notification_day_one_second) { create :user_notification, user: user, created_at: day_one }
    let!(:notification_day_two_first) { create :user_notification, user: user, created_at: day_two }

    before do
      login_as user
    end

    context "with notifications from different days" do
      it "correctly groups notifications by days created" do
        grouped_notifications = described_class.new.group_notifications(user)
        expect(grouped_notifications.keys).to eq [day_one.beginning_of_day, day_two.beginning_of_day]
        expect(grouped_notifications[day_one.beginning_of_day]).to eq [notification_day_one_first, notification_day_one_second]
        expect(grouped_notifications[day_two.beginning_of_day]).to eq [notification_day_two_first]
      end
    end
  end
end
