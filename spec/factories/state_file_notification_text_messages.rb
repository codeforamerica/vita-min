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
FactoryBot.define do
  factory :state_file_notification_text_message do
    body { "a text massage" }
    to_phone_number { "+14155551212" }
  end
end
