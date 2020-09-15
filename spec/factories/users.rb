# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  active                    :boolean
#  email                     :string           not null
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  name                      :string
#  provider                  :string
#  role                      :string
#  suspended                 :boolean
#  ticket_restriction        :string
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  zendesk_user_id           :bigint
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:uid)
    sequence(:email) { |n| "gary.gardengnome#{n}@example.green" }
  end
end
