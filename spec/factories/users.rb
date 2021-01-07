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
#  is_client_support         :boolean
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :string
#  locked_at                 :datetime
#  name                      :string
#  phone_number              :string
#  provider                  :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role_type                 :string
#  sign_in_count             :integer          default(0), not null
#  suspended                 :boolean
#  ticket_restriction        :string
#  timezone                  :string           default("America/New_York"), not null
#  two_factor_auth_enabled   :boolean
#  uid                       :string
#  verified                  :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invited_by_id             :bigint
#  role_id                   :bigint
#  zendesk_user_id           :bigint
#
# Indexes
#
#  index_users_on_email                  (email) UNIQUE
#  index_users_on_invitation_token       (invitation_token) UNIQUE
#  index_users_on_invitations_count      (invitations_count)
#  index_users_on_invited_by_id          (invited_by_id)
#  index_users_on_reset_password_token   (reset_password_token) UNIQUE
#  index_users_on_role_type_and_role_id  (role_type,role_id)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#
FactoryBot.define do
  factory :user do
    sequence(:uid)
    sequence(:email) { |n| "gary.gardengnome#{n}@example.green" }
    password { "userExamplePassword" }
    name { "Gary Gnome" }

    factory :organization_lead_user do
      transient do
        organization { nil }
      end

      role { create(:organization_lead_role, organization: organization || create(:organization)) }
    end

    factory :coalition_lead_user do
      transient do
        coalition { nil }
      end

      role { create(:coalition_lead_role, coalition: coalition || create(:coalition)) }
    end

    factory :site_coordinator_user do
      transient do
        site { nil }
      end

      role { create(:site_coordinator_role, site: site || create(:site)) }
    end

    factory :admin_user do
      role { create(:admin_role) }
    end

    factory :client_success_user do
      role { create(:client_success_role) }
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
