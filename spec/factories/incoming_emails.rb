# == Schema Information
#
# Table name: incoming_emails
#
#  id                 :bigint           not null, primary key
#  attachment_count   :integer
#  body_html          :string
#  body_plain         :string           not null
#  from               :citext           not null
#  received           :string
#  received_at        :datetime         not null
#  recipient          :string           not null
#  sender             :string           not null
#  stripped_html      :string
#  stripped_signature :string
#  stripped_text      :string
#  subject            :string
#  to                 :citext
#  user_agent         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  client_id          :bigint           not null
#  message_id         :string
#
# Indexes
#
#  index_incoming_emails_on_client_id  (client_id)
#
FactoryBot.define do
  factory :incoming_email do
    client
    to { "GetYourRefund <gyr@test.host>" }
    recipient { "gyr@test.host" }
    from { "Casey Cranberry <client@example.com>" }
    sender { "client@example.com" }
    body_plain { "Help me with my taxes please!\n\nCasey 🍒" }
    sequence(:received_at) { |n| DateTime.new(2020, 9, 2, 15, 1, 30) + n.minutes }
  end
end
