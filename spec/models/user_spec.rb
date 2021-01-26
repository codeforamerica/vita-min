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
      expect(user.errors).to include :role
    end

    it "validates timezone" do
      user = User.new(name: "Gary Guava", email: "example@example.com", password: "examplePassword", timezone: "Invalid timezone", role: AdminRole.new)
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

  describe "#accessible_coalitions" do
    let!(:coalition) { create(:coalition) }
    let!(:organization) { create(:organization, coalition: coalition) }
    let!(:site) { create(:site, parent_organization: organization) }
    let!(:other_coalition) { create(:coalition) }

    context "team member user" do
      let(:user) { create(:team_member_user, site: site) }

      it "does not include coalition" do
        expect(user.accessible_coalitions).to be_empty
      end
    end

    context "site coordinator user" do
      let(:user) { create(:site_coordinator_user, site: site) }

      it "does not include coalition" do
        expect(user.accessible_coalitions).to be_empty
      end
    end

    context "organization lead user" do
      let(:user) { create(:organization_lead_user, organization: organization) }

      it "does not include coalition" do
        expect(user.accessible_coalitions).to be_empty
      end
    end

    context "coalition lead user" do
      let(:user) { create(:coalition_lead_user, coalition: coalition) }

      it "includes the coalition" do
        expect(user.accessible_coalitions).to eq [coalition]
      end
    end

    context "admin user" do
      let(:user) { create(:admin_user) }

      it "includes all coalitions" do
        expect(user.accessible_coalitions).to match_array([coalition, other_coalition])
      end
    end

    context "greeter user" do
      let(:user) { create :user, role: create(:greeter_role, coalitions: [coalition])}

      it "includes the coalition" do
        expect(user.accessible_coalitions).to eq([coalition])
      end
    end
  end

  describe "#accessible_vita_partners" do
    context "team member user" do
      let!(:user) { create :team_member_user }
      let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }

      it "should return a user's site" do
        accessible_group_ids = user.accessible_vita_partners.pluck(:id)
        expect(accessible_group_ids).to include(user.role.site.id)
        expect(accessible_group_ids).not_to include(not_accessible_partner.id)
      end
    end

    context "site coordinator user" do
      let!(:user) { create :site_coordinator_user }
      let!(:unaccessible_site) { create :site }

      it "should return the user's site" do
        accessible_group_ids = user.accessible_vita_partners.pluck(:id)
        expect(accessible_group_ids).to include(user.role.site.id)
        expect(accessible_group_ids).not_to include(unaccessible_site.id)
      end
    end

    context "organization lead user" do
      let!(:organization) { create :organization, name: "Parent org" }
      let!(:site) { create :site, parent_organization: organization, name: "Child org" }
      let!(:user) { create :organization_lead_user, organization: organization }
      let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }

      it "should return a user's primary org and child sites" do
        accessible_group_ids = user.accessible_vita_partners.pluck(:id)
        expect(accessible_group_ids).to include(organization.id)
        expect(accessible_group_ids).to include(site.id)
        expect(accessible_group_ids).not_to include(not_accessible_partner.id)
      end
    end

    context "coalition lead user" do
      let!(:coalition) { create :coalition }
      let!(:organization) { create :organization, coalition: coalition }
      let!(:site) { create :site, parent_organization: organization }
      let!(:user) { create :coalition_lead_user, coalition: coalition }
      let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }

      it "should return a user's child orgs, and those orgs' child sites, but not coalition" do
        accessible_groups = user.accessible_vita_partners
        expect(accessible_groups).not_to include(coalition)
        expect(accessible_groups).to include(organization)
        expect(accessible_groups).to include(site)
        expect(accessible_groups).not_to include(not_accessible_partner)
      end
    end

    context "greeter user" do
      let!(:coalition) { create :coalition }
      let!(:organization) { create :organization, coalition: coalition }
      let!(:site) { create :site, parent_organization: organization }
      let!(:other_organization) { create :organization }
      let!(:other_site) { create :site, parent_organization: other_organization }
      let!(:not_accessible_partner) { create :vita_partner, name: "Not accessible" }
      let(:user) { create :user, role: create(:greeter_role, coalitions: [coalition], organizations: [other_organization]) }

      it "includes sites and organizations based on the hierarchy" do
        accessible_groups = user.accessible_vita_partners
        expect(accessible_groups).to match_array([organization, other_organization, site, other_site])
        expect(accessible_groups).not_to include(not_accessible_partner)
      end
    end

    context "admin user" do
      let!(:coalition) { create :coalition }
      let!(:organization) { create :organization, coalition: coalition }
      let!(:site) { create :site, parent_organization: organization }
      let!(:user) { create :admin_user }
      let!(:other_partner) { create :vita_partner, name: "accessible to admins" }

      it "should return all orgs and sites" do
        accessible_groups = user.accessible_vita_partners
        expect(accessible_groups).to include(organization)
        expect(accessible_groups).to include(other_partner)
        expect(accessible_groups).to include(site)
      end
    end
  end

  describe "#accessible_users" do
    let!(:coalition) { create :coalition }
    let!(:coalition_lead) { create :coalition_lead_user, coalition: coalition }
    let!(:sibling_coalition_lead) { create :coalition_lead_user, coalition: coalition }

    let!(:sibling_coalition) { create :coalition }
    let!(:cousin_coalition_lead) { create :coalition_lead_user, coalition: sibling_coalition }

    let!(:organization) { create :organization, coalition: coalition }
    let!(:organization_lead) { create :organization_lead_user, organization: organization }
    let!(:sibling_organization_lead) { create :organization_lead_user, organization: organization }

    let!(:sibling_organization) { create :organization, coalition: coalition }
    let!(:cousin_organization_lead) { create :organization_lead_user, organization: sibling_organization }

    let!(:site) { create :site, parent_organization: organization }
    let!(:site_coordinator) { create :site_coordinator_user, site: site }
    let!(:sibling_site_coordinator) { create :site_coordinator_user, site: site }
    let!(:team_member) { create :team_member_user, site: site }
    let!(:sibling_team_member) { create :team_member_user, site: site }

    let!(:sibling_site) { create :site, parent_organization: organization }
    let!(:cousin_site_coordinator) { create :site_coordinator_user, site: sibling_site }

    let(:admin) { create :admin_user }

    context "team member user" do
      it "return only the current user" do
        expected_results = [
          site_coordinator, sibling_site_coordinator,
          team_member, sibling_team_member
        ]
        expect(team_member.accessible_users).to match_array(expected_results)
      end
    end

    context "site coordinator user" do
      it "should return all the site coordinators and team members at the site" do
        expected_results = [
          site_coordinator, sibling_site_coordinator,
          team_member, sibling_team_member
        ]
        expect(site_coordinator.accessible_users).to match_array(expected_results)
      end
    end

    context "organization lead user" do
      it "should return all the team members, site coordinators, and organization leads under the organization" do
        expected_result = [
          organization_lead, sibling_organization_lead,
          site_coordinator, sibling_site_coordinator, cousin_site_coordinator,
          team_member, sibling_team_member
        ]
        expect(organization_lead.accessible_users).to match_array(expected_result)
      end
    end

    context "coalition lead user" do
      it "should return all team members, site coordinators, org leads, & coalition leads under the same coalition" do
        expected_result = [
          coalition_lead, sibling_coalition_lead,
          organization_lead, sibling_organization_lead, cousin_organization_lead,
          site_coordinator, sibling_site_coordinator, cousin_site_coordinator,
          team_member, sibling_team_member
        ]
        expect(coalition_lead.accessible_users).to match_array(expected_result)
      end
    end

    context "admin user" do
      it "should return all users" do
        expect(admin.accessible_users).to eq User.all
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

  describe "#admin?" do
    context "when the user has AdminRole type" do
      let(:user) { create :user, role: AdminRole.new }
      it "returns true" do
        expect(user.admin?).to be true
      end
    end

    context "when the user does not have AdminRole type" do
      let(:user) { create :user, role: GreeterRole.new }
      it "returns false" do
        expect(user.admin?).to be false
      end
    end
  end
end
