# == Schema Information
#
# Table name: clients
#
#  id               :bigint           not null, primary key
#  email_address    :string
#  phone_number     :string
#  preferred_name   :string
#  sms_phone_number :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :client do
    preferred_name { "Casey" }
    email_address { "client@example.com" }
    phone_number { "14155551212" }
    sms_phone_number { "14155551212" }
  end
end
