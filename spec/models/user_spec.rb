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
require "rails_helper"

RSpec.describe User, type: :model do
  describe "#valid?" do
    it "required fields" do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors).to include :name
      expect(user.errors).to include :password
      expect(user.errors).to include :email
    end

    it "validates timezone" do
      user = User.new(name: "Gary Guava", email: "example@example.com", password: "examplePassword", timezone: "Invalid timezone")
      expect(user).not_to be_valid
      expect(user.errors).to include :timezone
      user.timezone = "America/New_York"
      expect(user).to be_valid
    end

    context "when adding a role" do
      context "when the role is already attached to a different user" do
        let(:user) { create(:user) }
        let(:other_user) { create(:organization_lead_user) }

        it "is invalid" do
          expect(other_user).to be_valid
          expect(user).to be_valid
          user.role = other_user.role
          expect(user).not_to be_valid
        end
      end

      context "when two users have the same role type but different role id" do
        it "is valid" do
          role1 = create(:admin_role)
          role2 = create(:admin_role)
          user1 = create(:user, role: role1)
          user2 = build(:user, role: role2)

          expect(user1).to be_valid
          expect(user2).to be_valid
        end
      end
    end
  end

  describe "#accessible_organizations" do
    context "team member user" do
      let!(:user) { create :team_member_user }
      let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }

      it "should return a user's site" do
        accessible_group_ids = user.accessible_groups.pluck(:id)
        expect(accessible_group_ids).to include(user.role.site.id)
        expect(accessible_group_ids).not_to include(not_accessible_partner.id)
      end
    end

    context "organization lead user" do
      let!(:user) { create :user, role: create(:organization_lead_role, organization: organization) }
      let!(:organization) { create :organization, name: "Parent org" }
      let!(:site) { create :site, parent_organization: organization, name: "Child org" }
      let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }

      it "should return a user's primary org, supportable orgs, and coalition members" do
        accessible_group_ids = user.accessible_groups.pluck(:id)
        expect(accessible_group_ids).to include(organization.id)
        expect(accessible_group_ids).to include(site.id)
        expect(accessible_group_ids).not_to include(not_accessible_partner.id)
      end
    end

    context "site coordinator user" do
      let!(:user) { create :site_coordinator_user }
      let!(:unaccessible_site) { create :site }

      it "should return the user's site" do
        accessible_group_ids = user.accessible_groups.pluck(:id)
        expect(accessible_group_ids).to include(user.role.site.id)
        expect(accessible_group_ids).not_to include(unaccessible_site.id)
      end
    end
  end

  describe "first_name" do
    context "Luke" do
      let(:user) { build :user, name: "Luke"}
      it "returns nil" do
        expect(user.first_name).to eq "Luke"
      end
    end

    context "Luke Skywalker" do
      let(:user) { build :user, name: "Luke Skywalker"}
      it "returns nil" do
        expect(user.first_name).to eq "Luke"
      end
    end

    context "without name" do
      let(:user) { build :user, name: nil}
      it "returns nil" do
        expect(user.first_name).to eq nil
      end
    end
  end
end
