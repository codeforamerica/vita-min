# == Schema Information
#
# Table name: ctc_signups
#
#  id            :bigint           not null, primary key
#  email_address :string
#  name          :string
#  phone_number  :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
FactoryBot.define do
  factory :ctc_signup do
    name { "Gary Guava" }
    email_address { "example@example.com" }
    phone_number { "+14155551212" }
  end
end
