require "rails_helper"

RSpec.describe UserNotification do
  describe "#valid?" do
    describe "#notifiable" do
      context "with a random class that is not one of the allowed notifiable types" do
        let(:notifiable) { create :client }
        let(:user_notification) { build :user_notification, notifiable: notifiable }

        it "is not valid" do
          expect(user_notification).not_to be_valid
          expect(user_notification.errors[:notifiable_type]).to be_present
        end
      end

      context "with a class that is one of the allowed notifiable types" do
        let(:notifiable) { create :note }
        let(:user_notification) { build :user_notification, notifiable: notifiable }

        it "is valid" do
          expect(user_notification).to be_valid
          expect(user_notification.errors[:notifiable_type]).to be_empty
        end
      end
    end
  end
end