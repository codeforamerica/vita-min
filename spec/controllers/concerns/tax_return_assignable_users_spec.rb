require "rails_helper"

RSpec.describe TaxReturnAssignableUsers, type: :controller do

  controller(ApplicationController) do
    include TaxReturnAssignableUsers
  end

  describe "#assignable_users" do
    let(:client) { create :client, vita_partner: site }
    let(:site) { create :site }
    let(:organization) { create :organization}
    let!(:tax_return) { create :tax_return, client: client, assigned_user: assigned_user }

    let!(:assigned_user) { create :user, role: create(:team_member_role, site: site) }
    let!(:team_member) { create :user, role: create(:team_member_role, site: site) }
    let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, site: site) }
    let!(:org_lead) { create :user, role: create(:organization_lead_role, organization: organization) }
    let!(:inaccessible_user) { create :user }

    context "when the tax return is assigned to a site" do
      it "includes team members and site coordinators" do
        expect(subject.assignable_users(client, assigned_user)).to match_array [assigned_user, team_member, site_coordinator]
      end
    end

    context "when the tax return is assigned to an org" do
      let!(:client) { create :client, vita_partner: organization }

      it "includes assigned user and org leads" do
        expect(subject.assignable_users(client, assigned_user)).to match_array [assigned_user, org_lead]
      end
    end
  end
end
