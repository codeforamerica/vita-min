# == Schema Information
#
# Table name: outbound_calls
#
#  id                :bigint           not null, primary key
#  call_duration     :string
#  completed_at      :datetime
#  from_phone_number :string           not null
#  to_phone_number   :string           not null
#  twilio_sid        :string
#  twilio_status     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_outbound_calls_on_client_id  (client_id)
#  index_outbound_calls_on_user_id    (user_id)
#
class OutboundCall < ApplicationRecord
  belongs_to :user
  belongs_to :client
  validates :to_phone_number, phone: true, presence: true
  validates :from_phone_number, phone: true, presence: true
end
