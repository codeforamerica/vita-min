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
FactoryBot.define do
  factory :state_file_notification_email do
    body { "nothin" }
    subject { "Update from FileYourStateTaxes" }
    to { "outgoing@example.com" }
  end
end
