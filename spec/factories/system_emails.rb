# == Schema Information
#
# Table name: system_emails
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  sent_at    :datetime         not null
#  subject    :string           not null
#  to         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#
FactoryBot.define do
  factory :system_email do
    client
    body { "System email message body" }
  end
end
