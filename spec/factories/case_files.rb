# == Schema Information
#
# Table name: case_files
#
#  id               :bigint           not null, primary key
#  email_address    :string           not null
#  phone_number     :string           not null
#  preferred_name   :string           not null
#  sms_phone_number :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
FactoryBot.define do
  factory :case_file do
    preferred_name { "Casey" }
    email_address { "client@example.com" }
    phone_number { "14155551212" }
    sms_phone_number { "14155551212" }
  end
end
