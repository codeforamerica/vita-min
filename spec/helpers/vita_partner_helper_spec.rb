require "rails_helper"

describe VitaPartnerHelper do
  describe "#grouped_vita_partner_options" do
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

        expect(helper.grouped_vita_partner_options).to eq(expected)
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

        expect(helper.grouped_vita_partner_options).to eq(expected)
      end
    end

    context "when the user's role is Admin" do
      let(:org_1) { create(:organization, name: "First Org") }
      let(:org_2) { create(:organization, name: "Second Org") }
      let(:org_3) { create(:organization, name: "Org Without Sites") }
      let(:site_1) { create(:site, parent_organization_id: org_1.id, name: "1st Site of 1st Org") }
      let(:site_2) { create(:site, parent_organization_id: org_1.id, name: "2nd Site of 1st Org") }
      let(:site_3) { create(:site, parent_organization_id: org_2.id, name: "Site Of 2nd Org") }

      let(:admin) { create :admin_user }

      before do
        allow(view).to receive(:current_user).and_return(admin)
      end

      it "returns orgs & sites grouped by org including client support org" do
        @vita_partners = VitaPartner.accessible_by(Ability.new(admin))
        expected =
          [
            [VitaPartner.client_support_org.name, [[VitaPartner.client_support_org.name, VitaPartner.client_support_org.id]]],
            ["First Org", [["First Org", org_1.id], ["1st Site of 1st Org", site_1.id], ["2nd Site of 1st Org", site_2.id]]],
            ["Org Without Sites", [["Org Without Sites", org_3.id]]],
            ["Second Org", [["Second Org", org_2.id], ["Site Of 2nd Org", site_3.id]]],
          ]
        expect(helper.grouped_vita_partner_options).to match_array(expected)
      end
    end

    context "when the user's role is Coalition Lead" do
      let!(:org_1) { create(:organization, name: "First Org", coalition: coalition_lead.role.coalition) }
      let!(:org_2) { create(:organization, name: "Second Org", coalition: coalition_lead.role.coalition) }
      let!(:org_3) { create(:organization, name: "Org Without Sites", coalition: coalition_lead.role.coalition) }

      let!(:site_1) { create(:site, parent_organization_id: org_1.id, name: "1st Site of 1st Org") }
      let!(:site_2) { create(:site, parent_organization_id: org_1.id, name: "2nd Site of 2nd Org") }
      let!(:site_3) { create(:site, parent_organization_id: org_2.id, name: "Site of 2nd Org") }

      let!(:coalition_lead) { create :coalition_lead_user }

      before do
        allow(view).to receive(:current_user).and_return(coalition_lead)
      end

      it "returns orgs & sites grouped by org excluding client support org" do
        @vita_partners = VitaPartner.accessible_by(Ability.new(coalition_lead))
        expected =
          [
            ["First Org", [["First Org", org_1.id], ["1st Site of 1st Org", site_1.id], ["2nd Site of 2nd Org", site_2.id]]],
            ["Second Org", [["Second Org", org_2.id], ["Site of 2nd Org", site_3.id]]],
            ["Org Without Sites", [["Org Without Sites", org_3.id]]],
          ]
        expect(helper.grouped_vita_partner_options).to match_array(expected)
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
        expect(helper.grouped_vita_partner_options).to eq(expected)
      end
    end

    context "when the user's role is Greeter" do
      let!(:greeter) { create :greeter_user }
      let(:first_org) { create :organization, allows_greeters: true }
      let!(:site) { create :site, parent_organization: first_org }
      let(:second_org) { create :organization, allows_greeters: true }

      before do
        allow(view).to receive(:current_user).and_return(greeter)
      end

      it "returns array grouped by organization" do
        @vita_partners = greeter.accessible_vita_partners

        expected =
          [
            [first_org.name, [[first_org.name, first_org.id], [site.name, site.id]]],
            [second_org.name, [[second_org.name, second_org.id]]]
          ]
        expect(helper.grouped_vita_partner_options).to eq(expected)
      end
    end
  end
end
