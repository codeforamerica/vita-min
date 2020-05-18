# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  active                  :boolean
#  email                   :string
#  name                    :string
#  provider                :string
#  role                    :string
#  suspended               :boolean
#  ticket_restriction      :string
#  two_factor_auth_enabled :boolean
#  uid                     :string
#  verified                :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :bigint
#  zendesk_user_id         :bigint
#
FactoryBot.define do
  factory :user do
    provider { "zendesk" }
    uid { SecureRandom.random_number(100000) }
    email { "gary.gardengnome@example.green" }
  end
end
