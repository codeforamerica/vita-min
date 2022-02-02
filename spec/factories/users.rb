# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :string
#  email                     :citext           not null
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
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :string
#  locked_at                 :datetime
#  name                      :string
#  phone_number              :string
#  reset_password_sent_at    :datetime
#  reset_password_token      :string
#  role_type                 :string           not null
#  sign_in_count             :integer          default(0), not null
#  suspended_at              :datetime
#  timezone                  :string           default("America/New_York"), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invited_by_id             :bigint
#  role_id                   :bigint           not null
#
# Indexes
#
#  index_users_on_email                  (email)
#  index_users_on_invitation_token       (invitation_token) UNIQUE
#  index_users_on_invitations_count      (invitations_count)
#  index_users_on_invited_by_id          (invited_by_id)
#  index_users_on_reset_password_token   (reset_password_token) UNIQUE
#  index_users_on_role_type_and_role_id  (role_type,role_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "gary.gardengnome#{n}@example.com" }
    sequence(:name) { |n| "Gary Gnome the #{n}th" }
    password { "userExamplePassword" }
    role { build(:greeter_role) }

    factory :organization_lead_user do
      sequence(:email) { |n| "org.lead#{n}@example.com" }
      sequence(:name) { |n| "Org Lead the #{n}th" }

      transient do
        organization { nil }
      end

      role { build(:organization_lead_role, organization: organization || build(:organization)) }
    end

    factory :coalition_lead_user do
      sequence(:email) { |n| "coalition.lead#{n}@example.com" }
      sequence(:name) { |n| "Coalition Lead the #{n}th" }

      transient do
        coalition { nil }
      end

      role { build(:coalition_lead_role, coalition: coalition || build(:coalition)) }
    end

    factory :site_coordinator_user do
      sequence(:email) { |n| "site.coordinator#{n}@example.com" }
      sequence(:name) { |n| "Site Coordinator the #{n}th" }

      transient do
        site { nil }
      end

      role { build(:site_coordinator_role, site: site || build(:site)) }
    end

    factory :team_member_user do
      sequence(:email) { |n| "team.member#{n}@example.com" }

      sequence(:name) { |n| "Team Member the #{n}th" }

      transient do
        site { nil }
      end

      role { build(:team_member_role, site: site || build(:site)) }
    end

    factory :admin_user do
      sequence(:email) { |n| "#{Faker::Name.first_name}#{n}@example.com" }

      sequence(:name) { |n| "Admin the #{n}th" }

      role { build(:admin_role) }
    end

    factory :greeter_user do
      sequence(:email) { |n| "greeter#{n}@example.com" }
      sequence(:name) { |n| "Greeter the #{n}th" }

      role { build(:greeter_role) }
    end

    factory :client_success_user do
      sequence(:email) { |n| "client.success#{n}@example.com" }
      sequence(:name) { |n| "Client Success the #{n}th" }

      role { build(:client_success_role) }
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
