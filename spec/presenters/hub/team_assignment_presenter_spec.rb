require "rails_helper"

describe Hub::Dashboard::TeamAssignmentPresenter do
  # Users
  let!(:org_lead) { create :organization_lead_user, organization: oregano_org }
  let!(:other_org_lead) { create :organization_lead_user, organization: other_org }
  let(:site_coordinator) { create :site_coordinator_user, role: create(:site_coordinator_role, sites: [site, other_site]) }
  let!(:other_site_coordinator) { create :site_coordinator_user, role: create(:site_coordinator_role, sites: [other_org_child_site]) }
  let!(:coalition_lead) { create :coalition_lead_user, coalition: create(:coalition) }
  let(:team_member) { create :user, role: (create :team_member_role, sites: [site]) }
  let!(:other_team_member) { create :user, role: (create :team_member_role, sites: [other_site]) }
  let!(:inaccessible_team_member) { create :user, role: (create :team_member_role, sites: [create(:site)]) }

  # Vita Partners
  let(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition_lead.role.coalition }
  let(:other_org) { create :organization, name: "Other Org", coalition: coalition_lead.role.coalition }
  let(:site) { create :site, parent_organization: oregano_org }
  let(:other_site) { create :site, parent_organization: oregano_org }
  let(:other_org_child_site) { create :site, parent_organization: other_org }

  # Params
  let(:selected_model) { oregano_org }
  let(:page) { 1 }

  # Tax Returns
  let!(:assigned_tax_return_1) { create :gyr_tax_return, assigned_user: site_coordinator }
  let!(:assigned_tax_return_2) { create :gyr_tax_return, assigned_user: site_coordinator }
  let!(:assigned_tax_return_3) { create :gyr_tax_return, assigned_user: team_member }

  context "as a coalition lead" do
    subject { described_class.new(coalition_lead, page, selected_model) }

    context "when selecting a coalition" do
      let(:selected_model) { coalition_lead.role.coalition }

      it "returns no users" do
        expect(subject.ordered_by_tr_count_users).to eq nil
      end
    end

    context "when selecting an org" do
      it "shows org leads, team members and site coordinators belonging to selected org or child sites and their number of assigned tax returns in desc order" do
        expect(subject.ordered_by_tr_count_users).to eq [site_coordinator, team_member, org_lead, other_team_member]
      end

      context "when there are tax returns with archived clients" do
        it "doesn't count their tax returns" do
          create(:gyr_tax_return, assigned_user: site_coordinator, client: create(:client, filterable_product_year: 2023))

          expect(subject.ordered_by_tr_count_users.first.tax_returns_count).to eq 2
        end
      end

      context "when there are suspended users" do
        it "doesn't include them in the user group" do
          create(:user, role: (create :team_member_role, sites: [site]), suspended_at: Time.now)

          expect(subject.ordered_by_tr_count_users).to eq [site_coordinator, team_member, org_lead, other_team_member]
        end
      end
    end

    context "when selecting another org" do
      let(:selected_model) { other_org }

      it "doesn't show users from the other org" do
        expect(subject.ordered_by_tr_count_users).to eq [other_org_lead, other_site_coordinator]
      end
    end
  end

  context "as an org lead" do
    subject { described_class.new(org_lead, page, selected_model) }

    context "when selecting an organization in the drop down" do
      it "shows team members, org leads, site coordinators under that selected org or its child sites and their number of assigned tax returns in desc order" do
        expect(subject.ordered_by_tr_count_users).to eq [site_coordinator, team_member, org_lead, other_team_member]
      end
    end

    context "when selecting a site" do
      let(:selected_model) { site }

      it "shows team members, org leads, site coordinators under that site or with its parent org" do
        expect(subject.ordered_by_tr_count_users).to eq [site_coordinator, team_member, org_lead]
      end
    end
  end

  context "as an site coordinator" do
    subject { described_class.new(site_coordinator, page, selected_model) }

    context "when selecting a site" do
      let(:selected_model) { site }

      it "Site coordinators and team members that are assigned to selected site" do
        expect(subject.ordered_by_tr_count_users).to eq [site_coordinator, team_member]
      end
    end
  end
end