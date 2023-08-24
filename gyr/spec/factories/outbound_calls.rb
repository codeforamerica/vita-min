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
FactoryBot.define do
  factory :outbound_call do
    client
    user
    to_phone_number { "+15005550006" }
    from_phone_number { "+18324650000" }
  end
end
