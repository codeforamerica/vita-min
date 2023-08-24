# == Schema Information
#
# Table name: ctc_signups
#
#  id                          :bigint           not null, primary key
#  beta_email_sent_at          :datetime
#  email_address               :string
#  launch_announcement_sent_at :datetime
#  name                        :string
#  phone_number                :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
FactoryBot.define do
  factory :ctc_signup do
    name { "Gary Guava" }
    email_address { "example@example.com" }
    phone_number { "+14155551212" }
  end
end
