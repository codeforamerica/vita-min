# == Schema Information
#
# Table name: incoming_portal_messages
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint
#
# Indexes
#
#  index_incoming_portal_messages_on_client_id   (client_id)
#  index_incoming_portal_messages_on_created_at  (created_at)
#
FactoryBot.define do
  factory :incoming_portal_message do
    client
    body { "an incoming message from the portal" }
  end
end
