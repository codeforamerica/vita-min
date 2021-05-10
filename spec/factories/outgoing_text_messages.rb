# == Schema Information
#
# Table name: outgoing_text_messages
#
#  id              :bigint           not null, primary key
#  body            :string           not null
#  sent_at         :datetime
#  to_phone_number :string           not null
#  twilio_sid      :string
#  twilio_status   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :bigint           not null
#  user_id         :bigint
#
# Indexes
#
#  index_outgoing_text_messages_on_client_id  (client_id)
#  index_outgoing_text_messages_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :outgoing_text_message do
    client
    user
    body { "wyd" }
    to_phone_number { "+14155552345" }
  end
end
