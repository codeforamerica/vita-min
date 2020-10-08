# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  active                    :boolean
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string
#  email                     :string           not null
#  encrypted_access_token    :string
#  encrypted_access_token_iv :string
#  encrypted_password        :string           default(""), not null
#  failed_attempts           :integer          default(0), not null
#  invitation_accepted_at    :datetime
#  invitation_created_at     :datetime
#  invitation_limit          :integer
#  invitation_sent_at        :datetime
#  invitation_token          :string
#  invitations_count         :integer          default(0)
#  is_beta_tester            :boolean          default(FALSE), not null
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :string
#  locked_at                 :datetime
#  name                      :string
#  provider                  :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role                      :string
#  sign_in_count             :integer          default(0), not null
#  suspended                 :boolean
#  ticket_restriction        :string
#  timezone                  :string           default("America/New_York")
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invited_by_id             :bigint
#  vita_partner_id           :bigint
#  zendesk_user_id           :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_vita_partner_id       (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
FactoryBot.define do
  factory :user do
    sequence(:uid)
    sequence(:email) { |n| "gary.gardengnome#{n}@example.green" }
    password { "userExamplePassword" }
    name { "Gary Gnome" }

    factory :admin_user do
      role { "admin" }
    end

    factory :agent_user do
      role { "agent" }
    end

    factory :beta_tester do
      is_beta_tester { true }
    end

    factory :invited_user do
      association :invited_by, factory: :admin_user
      invitation_created_at { 1.day.ago - 1.minute }
      invitation_sent_at { 1.day.ago }
      sequence(:invitation_token) do |n|
        Devise.token_generator.digest(User, :invitation_token, "InvitationToken#{n}")
      end

      factory :accepted_invite_user do
        invitation_accepted_at { 1.minute.ago }
      end
    end
  end
end
