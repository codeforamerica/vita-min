require "rails_helper"

RSpec.describe TaxReturnAssignableUsers, type: :controller do

  controller(ApplicationController) do
    include TaxReturnAssignableUsers
  end

  describe "#assignable_users" do
    let(:client) { create :client, vita_partner: site }
    let(:site) { create :site, parent_organization: organization }
    let(:second_site) { create :site, parent_organization: organization }
    let(:organization) { create :organization }
    let!(:tax_return) { create :gyr_tax_return, client: client, assigned_user: assigned_user }

    let!(:assigned_user) { create :user, role: create(:team_member_role, sites: [site]) }
    let!(:team_member) { create :user, role: create(:team_member_role, sites: [site]) }
    let!(:legacy_team_member) { create :user, role: create(:team_member_role, legacy_vita_partner: site, sites: []) }
    let!(:another_team_member) { create :user, role: create(:team_member_role, sites: [second_site]) }
    let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, sites: [site]) }
    let!(:legacy_site_coordinator) { create :user, role: create(:site_coordinator_role, legacy_vita_partner: site, sites: []) }
    let!(:org_lead) { create :user, role: create(:organization_lead_role, organization: organization) }
    let!(:another_org_lead) { create :user, role: create(:organization_lead_role, organization: organization) }
    let!(:inaccessible_user) { create :user }

    context "when the tax return is assigned to a site" do
      it "includes the assigned user, site's team members, site coordinators, and the org leads" do
        expected_users = [
          assigned_user,
          team_member,
          site_coordinator,
          legacy_team_member,
          legacy_site_coordinator,
          org_lead,
          another_org_lead
        ]
        expect(subject.assignable_users(client, [assigned_user])).to match_array expected_users
      end
    end

    context "when the tax return is assigned to an org" do
      let!(:client) { create :client, vita_partner: organization }
      it "includes the assigned user, all sites' team members and coordinators under the org, and the other org leads" do
        expected_users = [
          assigned_user,
          another_team_member,
          team_member,
          site_coordinator,
          legacy_team_member,
          legacy_site_coordinator,
          org_lead,
          another_org_lead
        ]
        expect(subject.assignable_users(client, [assigned_user])).to match_array expected_users
      end
    end
  end
end
