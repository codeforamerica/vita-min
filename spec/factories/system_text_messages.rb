# == Schema Information
#
# Table name: system_text_messages
#
#  id              :bigint           not null, primary key
#  body            :string           not null
#  sent_at         :datetime         not null
#  to_phone_number :string           not null
#  twilio_sid      :string
#  twilio_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :bigint           not null
#
# Indexes
#
#  index_system_text_messages_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
FactoryBot.define do
  factory :system_text_message do
    client
    body { "system message body" }
    to_phone_number { "+14155552345" }
    sequence(:sent_at) { |n| DateTime.new(2020, 9, 2, 15, 1, 30) + n.minutes }
  end
end
