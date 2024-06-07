# == Schema Information
#
# Table name: outbound_calls
#
#  id                   :bigint           not null, primary key
#  from_phone_number    :string           not null
#  note                 :text
#  queue_time_ms        :integer
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
#  index_outbound_calls_on_client_id   (client_id)
#  index_outbound_calls_on_created_at  (created_at)
#  index_outbound_calls_on_user_id     (user_id)
#
class OutboundCall < ApplicationRecord
  belongs_to :user
  belongs_to :client
  validates :from_phone_number, :to_phone_number, e164_phone: true, presence: true

  after_create { InteractionTrackingService.record_user_initiated_outgoing_interaction(client) }
  after_create { InteractionTrackingService.update_last_outgoing_communication_at(client) }

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
    PhoneParser.formatted_phone_number(to_phone_number)
  end
end
