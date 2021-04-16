# == Schema Information
#
# Table name: user_notifications
#
#  id              :bigint           not null, primary key
#  notifiable_type :string
#  read            :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  notifiable_id   :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_user_notifications_on_notifiable_type_and_notifiable_id  (notifiable_type,notifiable_id)
#  index_user_notifications_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
