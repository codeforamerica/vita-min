# == Schema Information
#
# Table name: incoming_text_messages
#
#  id                :bigint           not null, primary key
#  body              :string
#  from_phone_number :string           not null
#  received_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  client_id         :bigint           not null
#
# Indexes
#
#  index_incoming_text_messages_on_client_id   (client_id)
#  index_incoming_text_messages_on_created_at  (created_at)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
FactoryBot.define do
  factory :incoming_text_message do
    client
    body { "nothin" }
    from_phone_number { "+14155537865" }
    sequence(:received_at) { |n| DateTime.new(2020, 9, 2, 15, 1, 30) + n.minutes }
  end
end
