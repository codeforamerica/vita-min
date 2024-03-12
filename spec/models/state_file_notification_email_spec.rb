# == Schema Information
#
# Table name: state_file_notification_emails
#
#  id               :bigint           not null, primary key
#  body             :string           not null
#  data_source_type :string
#  mailgun_status   :string           default("sending")
#  sent_at          :datetime
#  subject          :string           not null
#  to               :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  data_source_id   :bigint
#  message_id       :string
#
# Indexes
#
#  index_state_file_notification_emails_on_data_source  (data_source_type,data_source_id)
#
require "rails_helper"

describe StateFileNotificationEmail do
  describe "after create" do
    let(:email) { StateFileNotificationEmail.new(to: "test@example.com", body: "hi", subject: "test") }
    before do
      allow(email).to receive(:deliver)
    end

    it "calls deliver" do
      email.save!

      expect(email).to have_received(:deliver)
    end
  end
end
