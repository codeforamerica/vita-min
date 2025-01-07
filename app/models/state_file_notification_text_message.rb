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
class StateFileNotificationTextMessage < ApplicationRecord
  belongs_to :data_source, polymorphic: true, optional: true
  validates_presence_of :to_phone_number
  validates_presence_of :body
end
