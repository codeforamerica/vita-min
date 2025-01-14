# == Schema Information
#
# Table name: state_file_notification_text_messages
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  data_source_type :string
#  error_code       :string
#  sent_at          :datetime
#  to_phone_number  :string           not null
#  twilio_sid       :string
#  twilio_status    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  data_source_id   :bigint
#
# Indexes
#
#  index_state_file_notification_text_messages_on_data_source  (data_source_type,data_source_id)
#
require 'rails_helper'

RSpec.describe StateFileNotificationTextMessage, type: :model do
  describe "after create" do
    let(:text_message) { build :state_file_notification_text_message }
    before do
      allow(text_message).to receive(:deliver)
    end

    it "calls deliver" do
      text_message.save!

      expect(text_message).to have_received(:deliver)
    end
  end

  describe "#deliver" do
    it "queues a SendNotificationTextMessageJob" do
      text_message = build :state_file_notification_text_message
      expect {
        text_message.save!
      }.to have_enqueued_job(StateFile::SendNotificationTextMessageJob).with(text_message.id)
    end
  end
end
