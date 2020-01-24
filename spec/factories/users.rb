# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string
#  provider   :string
#  uid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :user do
    provider { "idme" }
    uid { SecureRandom.hex }
    email { "gary.gardengnome@example.green" }
  end
end
