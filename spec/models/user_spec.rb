# == Schema Information
#
# Table name: users
#
#  id                             :bigint           not null, primary key
#  current_sign_in_at             :datetime
#  current_sign_in_ip             :string
#  email                          :citext           not null
#  encrypted_password             :string           default(""), not null
#  external_provider              :string
#  external_uid                   :string
#  failed_attempts                :integer          default(0), not null
#  high_quality_password_as_of    :datetime
#  invitation_accepted_at         :datetime
#  invitation_created_at          :datetime
#  invitation_limit               :integer
#  invitation_sent_at             :datetime
#  invitation_token               :string
#  invitations_count              :integer          default(0)
#  last_sign_in_at                :datetime
#  last_sign_in_ip                :string
#  locked_at                      :datetime
#  name                           :string
#  phone_number                   :string
#  reset_password_sent_at         :datetime
#  reset_password_token           :string
#  role_type                      :string           not null
#  should_enforce_strong_password :boolean          default(FALSE), not null
#  sign_in_count                  :integer          default(0), not null
#  suspended_at                   :datetime
#  timezone                       :string           default("America/New_York"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  invited_by_id                  :bigint
#  role_id                        :bigint           not null
#
# Indexes
#
#  index_users_on_email                  (email) UNIQUE
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
require "rails_helper"

RSpec.describe User, type: :model, requires_default_vita_partners: true do
  describe "#valid?" do
    it "required fields" do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors).to include :name
      expect(user.errors).to include :password
      expect(user.errors).to include :email
      expect(user.errors).to include :role
    end

    context "with an invalid email" do
      let(:user) { build(:user, email: "someone@example") }

      it "is not valid and adds an error to the email" do
        expect(user).not_to be_valid
        expect(user.errors).to include :email
      end

      context "when the email address looks valid, but the domain's DNS configuration doesn't accept email" do
        let(:user) { build(:user, email: "someone@example.com") }
        before do
          allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?).and_return(false)
        end

        it "is not valid and adds an error to the email" do
          expect(user).not_to be_valid
          expect(user.errors).to include :email
        end
      end
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

        it "appears valid, but raises an error when saving" do
          expect(other_user).to be_valid
          user.role = other_user.role
          expect(user).to be_valid
          expect do
            user.save
          end.to raise_error(ActiveRecord::RecordNotUnique)
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

    context "password validation" do
      let(:password) { "aConventionallyStrong!Password3" }
      let(:password_confirmation) { password }
      let(:role) { GreeterRole.new }
      let(:user) { build(:user, password: password, password_confirmation: password_confirmation, role: role) }

      context "length" do
        context "when too short" do
          let(:password) { "short" }

          it "is not valid" do
            expect(user).not_to be_valid
            expect(user.errors[:password]).to include I18n.t("errors.attributes.password.too_short", count: 10)
          end
        end

        context "when too long" do
          let(:password) { "tooShort".ljust(512, "tooLong") }

          it "is not valid" do
            expect(user).not_to be_valid
            expect(user.errors[:password]).to include("is too long (maximum is 128 characters)")
          end
        end

        context "when just right" do
          let(:password) { "tooShort".ljust(50, "tooLong") }

          it "is valid" do
            expect(user).to be_valid
          end
        end
      end

      context "strength" do
        context "when strong enough" do
          it "is valid" do
            expect(user).to be_valid
          end
        end

        context "when too weak" do
          let(:password) { "password" }

          it "is invalid" do
            expect(user).not_to be_valid
            expect(user.errors[:password]).to include(I18n.t("errors.attributes.password.insecure"))
          end
        end
      end

      context "confirmation" do
        context "not matching" do
          let(:password_confirmation) { "thisCantMatch" }

          it "is not valid" do
            expect(user).not_to be_valid
            expect(user.errors[:password_confirmation]).to include(I18n.t("errors.attributes.password.not_matching"))
          end
        end

        context "matching" do
          let(:password_confirmation) { password }
          it "is valid" do
            expect(user).to be_valid
          end
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
      let(:user) { create(:team_member_user, sites: [site]) }

      it "does not include coalition" do
        expect(user.accessible_coalitions).to be_empty
      end
    end

    context "site coordinator user" do
      let(:user) { create(:site_coordinator_user, sites: [site]) }

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

    context "greeter user" do
      let(:user) { create :user, role: create(:greeter_role) }

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
  end

  describe "#accessible_vita_partners" do
    context "team member user" do
      let!(:user) { create :team_member_user }
      let!(:not_accessible_partner) { create :site, name: "Not accessible" }

      it "should return a user's site" do
        accessible_group_ids = user.accessible_vita_partners.pluck(:id)
        expect(accessible_group_ids).to match_array(user.role.sites.map(&:id))
        expect(accessible_group_ids).not_to include(not_accessible_partner.id)
      end
    end

    context "site coordinator user" do
      let!(:user) { create :site_coordinator_user }
      let!(:unaccessible_site) { create :site }

      it "should return the user's site" do
        accessible_group_ids = user.accessible_vita_partners.pluck(:id)
        expect(accessible_group_ids).to match_array(user.role.sites.map(&:id))
        expect(accessible_group_ids).not_to include(unaccessible_site.id)
      end
    end

    context "organization lead user" do
      let!(:organization) { create :organization, name: "Parent org" }
      let!(:site) { create :site, parent_organization: organization, name: "Child org" }
      let!(:user) { create :organization_lead_user, organization: organization }
      let!(:not_accessible_partner) { create :site, name: "Not accessible" }

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
      let!(:not_accessible_partner) { create :organization, name: "Not accessible" }

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
      let!(:organization) { create :organization, coalition: coalition, allows_greeters: true }
      let!(:site) { create :site, parent_organization: organization }
      let!(:other_organization) { create :organization, allows_greeters: true }
      let!(:other_site) { create :site, parent_organization: other_organization }
      let!(:not_accessible_org) { create :organization, name: "Not accessible", allows_greeters: false }
      let!(:not_accessible_site) { create :site, parent_organization: not_accessible_org }
      let(:user) { create :user, role: create(:greeter_role) }

      it "returns all the organizations (and their sites) where allows greeters is true" do
        accessible_groups = user.accessible_vita_partners
        national_org = VitaPartner.where(name: "GYR National Organization").first
        expect(accessible_groups).to match_array([national_org, organization, other_organization, site, other_site])
        expect(accessible_groups).not_to include(not_accessible_org)
        expect(accessible_groups).not_to include(not_accessible_site)
      end
    end

    context "admin user" do
      let!(:coalition) { create :coalition }
      let!(:organization) { create :organization, coalition: coalition }
      let!(:site) { create :site, parent_organization: organization }
      let!(:user) { create :admin_user }
      let!(:other_partner) { create :site, name: "accessible to admins" }

      it "should return all orgs and sites" do
        accessible_groups = user.accessible_vita_partners
        expect(accessible_groups).to include(organization)
        expect(accessible_groups).to include(other_partner)
        expect(accessible_groups).to include(site)
      end
    end

    context "customer support user" do
      let!(:coalition) { create :coalition }
      let!(:organization) { create :organization, coalition: coalition }
      let!(:site) { create :site, parent_organization: organization }
      let!(:user) { create :client_success_user }
      let!(:other_partner) { create :site, name: "accessible to admins" }

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
    let!(:site_coordinator) { create :site_coordinator_user, sites: [site] }
    let!(:sibling_site_coordinator) { create :site_coordinator_user, sites: [site] }
    let!(:team_member) { create :team_member_user, sites: [site] }
    let!(:sibling_team_member) { create :team_member_user, sites: [site] }

    let!(:sibling_site) { create :site, parent_organization: organization }
    let!(:cousin_site_coordinator) { create :site_coordinator_user, sites: [sibling_site] }

    let(:admin) { create :admin_user }

    context "team member user" do
      it "should return all the site coordinators and team members at the site, and the org leads" do
        expected_results = [
          organization_lead, sibling_organization_lead,
          site_coordinator, sibling_site_coordinator,
          team_member, sibling_team_member
        ]
        expect(team_member.accessible_users).to match_array(expected_results)
      end
    end

    context "site coordinator user" do
      it "should return all the site coordinators and team members at the site, and the org leads" do
        expected_results = [
          organization_lead, sibling_organization_lead,
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

  describe ".taggable_for" do
    let(:admin_user) { create :admin_user }
    let(:client_success_user) { create :client_success_user }
    let(:greeter_user) { create :greeter_user }

    let!(:outside_coalition_lead_user) { create :coalition_lead_user }
    let!(:outside_organization_lead_user) { create :organization_lead_user }
    let!(:outside_site_coordinator_user) { create :site_coordinator_user }
    let!(:outside_team_member_user) { create :team_member_user }

    let(:client_coalition) { create :coalition }
    let(:client_organization) { create :organization, coalition: client_coalition }
    let(:client_site) { create :site, parent_organization: client_organization }

    let(:coalition_lead_user) { create :coalition_lead_user, coalition: client_coalition }
    let(:organization_lead_user) { create :organization_lead_user, organization: client_organization }
    let(:site_coordinator_user) { create :site_coordinator_user, sites: [client_site] }
    let(:team_member_user) { create :team_member_user, sites: [client_site] }

    context "with a client assigned to an organization" do

      let(:client) { create :client, vita_partner: client_organization }

      it "includes users who can access the client" do
        expect(User.taggable_for(client)).to contain_exactly(admin_user, client_success_user, greeter_user, coalition_lead_user, organization_lead_user)
      end
    end

    context "with a client assigned to a site" do
      let(:client) { create :client, vita_partner: client_site }
      it "includes users who can access the client" do
        expect(User.taggable_for(client)).to contain_exactly(admin_user, client_success_user, greeter_user, coalition_lead_user, organization_lead_user, site_coordinator_user, team_member_user)
      end
    end

    context "with an unassigned client" do
      let(:client) { create :client, vita_partner: nil }
      it "includes users who can access the client" do
        expect(User.taggable_for(client)).to contain_exactly(admin_user, client_success_user, greeter_user)
      end
    end
  end

  describe "first_name" do
    context "Luke" do
      let(:user) { build :user, name: "Luke" }
      it "returns nil" do
        expect(user.first_name).to eq "Luke"
      end
    end

    context "Luke Skywalker" do
      let(:user) { build :user, name: "Luke Skywalker" }
      it "returns nil" do
        expect(user.first_name).to eq "Luke"
      end
    end

    context "without name" do
      let(:user) { build :user, name: nil }
      it "returns nil" do
        expect(user.first_name).to eq nil
      end
    end
  end

  describe "#admin?" do
    context "when the user has AdminRole type" do
      let(:user) { create :admin_user }
      it "returns true" do
        expect(user.admin?).to be true
      end
    end

    context "when the user does not have AdminRole type" do
      let(:user) { create :greeter_user }
      it "returns false" do
        expect(user.admin?).to be false
      end
    end
  end

  describe "#greeter?" do
    context "when the user has GreeterRole type" do
      let(:user) { create :greeter_user }
      it "returns true" do
        expect(user.greeter?).to be true
      end
    end

    context "when the user does not have GreeterRole type" do
      let(:user) { create :team_member_user }
      it "returns false" do
        expect(user.greeter?).to be false
      end
    end
  end

  describe "#org_lead?" do
    context "when the user has OrganizationLeadRole type" do
      let(:user) { create :organization_lead_user }
      it "returns true" do
        expect(user.org_lead?).to be true
      end
    end

    context "when the user does not have OrganizationLeadRole type" do
      let(:user) { create :team_member_user }
      it "returns false" do
        expect(user.org_lead?).to be false
      end
    end
  end

  describe "#site_coordinator?" do
    context "when the user has SiteCoordinatorRole type" do
      let(:user) { create :site_coordinator_user }
      it "returns true" do
        expect(user.site_coordinator?).to be true
      end
    end

    context "when the user does not have SiteCoordinatorRole type" do
      let(:user) { create :team_member_user }
      it "returns false" do
        expect(user.site_coordinator?).to be false
      end
    end
  end

  describe "#coalition_lead?" do
    context "when the user has CoalitionLeadRole type" do
      let(:user) { create :coalition_lead_user }
      it "returns true" do
        expect(user.coalition_lead?).to be true
      end
    end

    context "when the user does not have CoalitionLeadRole type" do
      let(:user) { create :team_member_user }
      it "returns false" do
        expect(user.coalition_lead?).to be false
      end
    end
  end

  describe "#team_member?" do
    context "when the user has TeamMemberRole type" do
      let(:user) { create :team_member_user }
      it "returns true" do
        expect(user.team_member?).to be true
      end
    end

    context "when the user does not have TeamMemberRole type" do
      let(:user) { create :coalition_lead_user }
      it "returns false" do
        expect(user.team_member?).to be false
      end
    end
  end


  describe "#state_file_admin?" do
    context "when the user has AdminRole type and state_file is true" do
      let(:user) { create :admin_user, role: role }
      let(:role) { create :admin_role, state_file: true }
      it "returns true" do
        expect(user.state_file_admin?).to be true
      end
    end

    context "when the user does not have AdminRole type" do
      let(:user) { create :greeter_user }
      it "returns false" do
        expect(user.state_file_admin?).to be false
      end
    end

    context "when the user does have AdminRole type and state_file is false" do
      let(:user) { create :admin_user, role: role }
      let(:role) { create :admin_role, state_file: false }
      it "returns false" do
        expect(user.state_file_admin?).to be false
      end
    end
  end

  describe ".active" do
    let!(:user) { create :user }
    let!(:suspended_user) { create :user, suspended_at: DateTime.now }

    it "does not include suspended users" do
      expect(User.active).to match_array([user])
    end
  end

  describe "#served_entities" do
    context "an admin user" do
      let(:user) { create :admin_user }
      it "returns nil" do
        expect(user.served_entities).to eq nil
      end
    end

    context "a client success user" do
      let(:user) { create :client_success_user }
      it "returns nil" do
        expect(user.served_entities).to eq nil
      end
    end

    context "a greeter user" do
      let(:user) { create :greeter_user }
      it "returns nil" do
        expect(user.served_entities).to eq nil
      end
    end

    context "a team member user" do
      let(:site) { create :site }
      let(:user) { create :team_member_user, sites: [site] }
      it "returns their site" do
        expect(user.served_entities).to eq [site]
      end
    end

    context "a coalition lead user" do
      let(:coalition) { create :coalition }
      let(:user) { create :coalition_lead_user, coalition: coalition }
      it "returns their coalition" do
        expect(user.served_entities).to eq [coalition]
      end
    end

    context "a org lead user" do
      let(:organization) { create :organization }
      let(:user) { create :organization_lead_user, organization: organization }
      it "returns their organization" do
        expect(user.served_entities).to eq [organization]
      end
    end

    context "a site coordinator user" do
      let(:site) { create :site }
      let(:user) { create :site_coordinator_user, sites: [site] }
      it "returns their organization" do
        expect(user.served_entities).to eq [site]
      end
    end
  end

  describe "#role_name" do
    context "an admin" do
      let(:user) { create :admin_user }
      it "is Admin" do
        expect(user.role_name).to eq "Admin"
      end
    end

    context "a team member" do
      let(:user) { create :team_member_user }
      it "is Admin" do
        expect(user.role_name).to eq "Team Member"
      end
    end

    context "site coordinator" do
      let(:user) { create :site_coordinator_user }
      it "is Site Coordinator" do
        expect(user.role_name).to eq "Site Coordinator"
      end
    end

    context "coalition lead" do
      let(:user) { create :coalition_lead_user }
      it "is Admin" do
        expect(user.role_name).to eq "Coalition Lead"
      end
    end

    context "organization lead" do
      let(:user) { create :organization_lead_user }
      it "is Admin" do
        expect(user.role_name).to eq "Organization Lead"
      end
    end
  end

  describe "#name_with_role_and_entity" do
    context "an admin" do
      let(:user) { create :admin_user, name: "Some Name" }
      it "is Admin" do
        expect(user.name_with_role_and_entity).to eq "Some Name (Admin)"
      end
    end

    context "a team member" do
      let(:user) { create :team_member_user, name: "Marty Melon", sites: [create(:site, name: "New Site")] }
      it "is Admin" do
        expect(user.name_with_role_and_entity).to eq "Marty Melon (Team Member) - New Site"
      end

      context "a team member with multiple sites" do
        it "returns the first site name and the number of additional sites" do
          user.role.sites << create(:site, name: "New Site2")
          user.role.sites << create(:site, name: "New Site3")
          expect(user.name_with_role_and_entity).to eq "Marty Melon (Team Member) - New Site (and 2 more)"
        end
      end
    end

    context "site coordinator" do
      let(:user) { create :site_coordinator_user, name: "Luna Lemon", sites: [create(:site, name: "New Site")] }
      it "is Site Coordinator" do
        expect(user.name_with_role_and_entity).to eq "Luna Lemon (Site Coordinator) - New Site"
      end
    end

    context "coalition lead" do
      let(:user) { create :coalition_lead_user, name: "Martha Mango", coalition: (create :coalition, name: "This Coalition") }
      it "is Admin" do
        expect(user.name_with_role_and_entity).to eq "Martha Mango (Coalition Lead) - This Coalition"
      end
    end

    context "organization lead" do
      let(:user) { create :organization_lead_user, name: "Patty Persimmon", organization: (create :organization, name: "Some Org") }
      it "is Admin" do
        expect(user.name_with_role_and_entity).to eq "Patty Persimmon (Organization Lead) - Some Org"
      end
    end
  end

  describe ".google_login_domain?" do
    context "with an @codeforamerica.org email address" do
      it "returns true" do
        expect(described_class.google_login_domain?("example@codeforamerica.org")).to eq(true)
      end
    end

    context "with a CfA email address capitalized" do
      it "returns true" do
        expect(described_class.google_login_domain?("example@codeforAmerica.org")).to eq(true)
      end
    end

    context "with a regular old email address" do
      it "returns false" do
        expect(described_class.google_login_domain?("example@example.com")).to eq(false)
      end
    end
  end

  describe ".from_omniauth" do
    let(:email) { "bettyboop@codeforamerica.org" }
    let(:suspended_at) { nil }
    let!(:user) { create :admin_user, email: email, suspended_at: suspended_at }
    let(:provider) { "google_oauth2" }
    let(:auth_hash) { OmniAuth::AuthHash.new(provider: provider, uid: "12345678901234567890", info: { email: email, name: "Betty Boop" }, extra: { "id_info" => { "hd" => email.split("@")[1] } }) }

    context "has a @codeforamerica.org email" do
      context "has an admin account" do
        it "returns a user" do
          expect(User.from_omniauth(auth_hash)).to eq user
        end

        context "when the login comes from a non-Google provider" do
          let(:provider) { "wrong_provider" }
          it "returns nil" do
            expect(User.from_omniauth(auth_hash)).to eq nil
          end
        end

        context "when the user is logging in for the first time" do
          it "updates the uid and provider" do
            expect do
              User.from_omniauth(auth_hash)
            end.to change { user.reload.external_provider }.from(nil).to(provider)
                                                           .and change { user.reload.external_uid }.from(nil).to("12345678901234567890")
          end
        end

        context "when logging in with Google the next time" do
          context "if the UID is different" do
            let!(:user) { create :admin_user, email: email, external_provider: provider, external_uid: "something_else" }
            it "returns nil" do
              expect(User.from_omniauth(auth_hash)).to eq nil
            end
          end
        end
      end

      context "is a greeter account" do
        let!(:user) { create :greeter_user, email: email }

        it "returns nil" do
          expect(User.from_omniauth(auth_hash)).to eq nil
        end
      end
    end

    context "has a @getyourrefund.org email" do
      let(:email) { "bettyboop@getyourrefund.org" }

      context "has an admin account" do
        it "returns a user" do
          expect(User.from_omniauth(auth_hash)).to eq user
        end
      end
    end

    context "has a @gmail.com email" do
      let(:email) { "bettyboop@gmail.com" }

      it "returns nil" do
        expect(User.from_omniauth(auth_hash)).to eq nil
      end
    end

    context "has a suspended email" do
      let(:suspended_at) { DateTime.now }

      it "returns nil" do
        expect(User.from_omniauth(auth_hash)).to eq nil
      end
    end
  end
end
