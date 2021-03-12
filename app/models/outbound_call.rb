# == Schema Information
#
# Table name: outbound_calls
#
#  id                   :bigint           not null, primary key
#  from_phone_number    :string           not null
#  note                 :text
#  to_phone_number      :string           not null
#  twilio_call_duration :integer
#  twilio_sid           :string
#  twilio_status        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  client_id            :bigint
#  user_id              :bigint
#
# Indexes
#
#  index_outbound_calls_on_client_id  (client_id)
#  index_outbound_calls_on_user_id    (user_id)
#
class OutboundCall < ApplicationRecord
  include InteractionTracking
  belongs_to :user
  belongs_to :client
  validates :to_phone_number, phone: true, presence: true
  validates :from_phone_number, phone: true, presence: true

  after_create :record_outgoing_interaction

  # twilio_status, twilio_sid, and call_duration are set by responses from twilio
  # twilio_status is set to "queued" on creation of the twilio call which triggers a call to the from_phone_number
  # a webhook on the "dial" to the to_phone_number will trigger updates to the twilio_status
  # This means that if a user ends the call before completing the dial event to the client, the call will remain in
  # the "queued" status until the dial event to the client is completed.
  #
  def self.twilio_number
    EnvironmentCredentials.dig(:twilio, :voice_phone_number)
  end

  def to
    Phonelib.parse(to_phone_number, "US").local_number
  end
end
