# == Schema Information
#
# Table name: state_file_notification_emails
#
#  id             :bigint           not null, primary key
#  body           :string           not null
#  mailgun_status :string           default("sending")
#  sent_at        :datetime
#  subject        :string           not null
#  to             :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  message_id     :string
#
FactoryBot.define do
  factory :state_file_notification_email do
    body { "nothin" }
    subject { "Update from FileYourStateTaxes" }
    to { "outgoing@example.com" }
  end
end
