# == Schema Information
#
# Table name: signups
#
#  id                            :bigint           not null, primary key
#  ctc_2022_open_message_sent_at :datetime
#  email_address                 :citext
#  name                          :string
#  phone_number                  :string
#  puerto_rico_open_sent_at      :datetime
#  zip_code                      :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
FactoryBot.define do
  factory :signup do
    name { "Gary Guava" }
    zip_code { "94110" }
    email_address { "example@example.com" }
    phone_number { "+14155551212" }
  end
end
