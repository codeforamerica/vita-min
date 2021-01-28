require "rails_helper"

describe VitaPartnerHelper do
  describe "#grouped_organization_options" do
    context "when user's role is Team Member" do
      let(:team_member) { create :team_member_user }

      before do
        allow(view).to receive(:current_user).and_return(team_member)
      end

      it "returns just the user's site and the org" do
        @vita_partners = team_member.accessible_vita_partners
        expected = [
          [
            team_member.role.site.parent_organization.name,
            [[team_member.role.site.name, team_member.role.site.id]]
          ]
        ]

        expect(helper.grouped_organization_options).to eq(expected)
      end
    end

    context "when the user's role is Site Coordinator" do
      let(:site_coordinator) { create :site_coordinator_user }

      before do
        allow(view).to receive(:current_user).and_return(site_coordinator)
      end

      it "returns just the user's site and the org" do
        @vita_partners = VitaPartner.accessible_by(Ability.new(site_coordinator))
        expected = [
          [
            site_coordinator.role.site.parent_organization.name,
            [[site_coordinator.role.site.name, site_coordinator.role.site.id]]
          ]
        ]

        expect(helper.grouped_organization_options).to eq(expected)
      end
    end

    context "when the user's role is Admin" do
      let(:org_1) { create(:vita_partner, name: "First Parent Org") }
      let(:org_2) { create(:vita_partner, name: "Second Parent Org") }
      let(:org_3) { create(:vita_partner, name: "No Child Org") }
      let(:site_1) { create(:vita_partner, parent_organization_id: org_1.id, name: "The First Child Org") }
      let(:site_2) { create(:vita_partner, parent_organization_id: org_1.id, name: "The Second Child Org") }
      let(:site_3) { create(:vita_partner, parent_organization_id: org_2.id, name: "The Third Child Org") }

      let(:admin) { create :admin_user }

      before do
        allow(view).to receive(:current_user).and_return(admin)
      end

      it "returns arrays of sites grouped by parent orgs" do
        @vita_partners = VitaPartner.accessible_by(Ability.new(admin))
        expected =
          [
            [VitaPartner.client_support_org.name, [[VitaPartner.client_support_org.name, VitaPartner.client_support_org.id]]],
            ["First Parent Org", [["First Parent Org", org_1.id], ["The First Child Org", site_1.id], ["The Second Child Org", site_2.id]]],
            ["No Child Org", [["No Child Org", org_3.id]]],
            ["Second Parent Org", [["Second Parent Org", org_2.id], ["The Third Child Org", site_3.id]]],
          ]
        expect(helper.grouped_organization_options).to eq(expected)
      end
    end

    context "when the user's role is Coalition Lead" do
      let!(:org_1) { create(:organization, name: "First Parent Org", coalition: coalition_lead.role.coalition) }
      let!(:org_2) { create(:organization, name: "Second Parent Org", coalition: coalition_lead.role.coalition) }
      let!(:org_3) { create(:organization, name: "No Child Org", coalition: coalition_lead.role.coalition) }

      let!(:site_1) { create(:site, parent_organization_id: org_1.id, name: "The First Child Site") }
      let!(:site_2) { create(:site, parent_organization_id: org_1.id, name: "The Second Child Site") }
      let!(:site_3) { create(:site, parent_organization_id: org_2.id, name: "The Third Child Site") }

      let!(:coalition_lead) { create :coalition_lead_user }

      before do
        allow(view).to receive(:current_user).and_return(coalition_lead)
      end

      it "returns array grouped by parent org" do
        @vita_partners = VitaPartner.accessible_by(Ability.new(coalition_lead))
        expected =
          [
            ["First Parent Org", [["First Parent Org", org_1.id], ["The First Child Site", site_1.id], ["The Second Child Site", site_2.id]]],
            ["Second Parent Org", [["Second Parent Org", org_2.id], ["The Third Child Site", site_3.id]]],
            ["No Child Org", [["No Child Org", org_3.id]]],
          ]
        expect(helper.grouped_organization_options).to eq(expected)
      end
    end

    context "when the user's role is the Organization Lead" do
      let!(:site) { create :site, parent_organization: organization_lead.role.organization }
      let!(:organization_lead) { create :organization_lead_user }

      before do
        allow(view).to receive(:current_user).and_return(organization_lead)
      end

      it "returns array grouped by organization" do
        @vita_partners = VitaPartner.accessible_by(Ability.new(organization_lead))
        expected =
          [
            [organization_lead.role.organization.name, [[organization_lead.role.organization.name, organization_lead.role.organization.id], [site.name, site.id]]],
          ]
        expect(helper.grouped_organization_options).to eq(expected)
      end
    end
  end
end
