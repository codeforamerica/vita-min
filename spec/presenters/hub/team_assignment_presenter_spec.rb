require "rails_helper"

describe Hub::Dashboard::TeamAssignmentPresenter do
  let!(:org_lead_user) { create :organization_lead_user, organization: oregano_org }
  let!(:other_org_lead_user) { create :organization_lead_user, organization: other_org }
  let!(:site_coordinator_user) { create :site_coordinator_user, role: create(:site_coordinator_role, sites: [site]) }
  let!(:coalition_lead) { create :coalition_lead_user, coalition: create(:coalition) }
  let!(:team_member) { create :user, role: (create :team_member_role, sites: [site]) }
  let!(:other_team_member) { create :user, role: (create :team_member_role, sites: [other_site]) }
  let!(:inaccessible_team_member) { create :user, role: (create :team_member_role, sites: [create(:site)]) }

  let(:page) { 1 }
  let(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition_lead.role.coalition }
  let(:other_org) { create :organization, name: "Other Org", coalition: coalition_lead.role.coalition }
  let(:site) { create :site, parent_organization: oregano_org }
  let(:other_site) { create :site, parent_organization: oregano_org }
  let(:selected_model) { oregano_org }

  let!(:assigned_tax_return_1) { create :gyr_tax_return, assigned_user: site_coordinator_user }
  let!(:assigned_tax_return_2) { create :gyr_tax_return, assigned_user: site_coordinator_user }
  let!(:assigned_tax_return_3) { create :gyr_tax_return, assigned_user: team_member }

  context "as an org lead" do
    subject { described_class.new(org_lead_user, page, selected_model) }

    it "shows accessible users and their number of assigned tax returns in descending order" do
      expect(subject.ordered_by_tr_count_users).to eq [site_coordinator_user, team_member, org_lead_user, other_team_member]
      expect(subject.ordered_by_tr_count_users).not_to include inaccessible_team_member
      expect(subject.ordered_by_tr_count_users).not_to include coalition_lead
    end

    context "when selecting a site" do
      let(:selected_model) { site }

      it "doesn't show users that are apart of other sites" do
        expect(subject.ordered_by_tr_count_users).not_to include other_team_member
      end
    end
  end

  context "as an site coordinator" do
    subject { described_class.new(site_coordinator_user, page, selected_model) }

    it "shows accessible users and their number of assigned tax returns in descending order" do
      expect(subject.ordered_by_tr_count_users).to eq [site_coordinator_user, team_member]
      expect(subject.ordered_by_tr_count_users).not_to include inaccessible_team_member
      expect(subject.ordered_by_tr_count_users).not_to include coalition_lead
      expect(subject.ordered_by_tr_count_users).not_to include other_team_member
    end
  end

  context "as a coalition lead" do
    subject { described_class.new(coalition_lead, page, selected_model) }

    it "shows accessible users and their number of assigned tax returns in descending order" do
      expect(subject.ordered_by_tr_count_users).to eq [site_coordinator_user, team_member, org_lead_user, other_team_member]
      expect(subject.ordered_by_tr_count_users).not_to include inaccessible_team_member
      expect(subject.ordered_by_tr_count_users).not_to include coalition_lead
    end

    context "when selecting another org" do
      let(:selected_model) { other_org }

      it "doesn't show users that are apart of other sites" do
        expect(subject.ordered_by_tr_count_users).to include other_org_lead_user
        expect(subject.ordered_by_tr_count_users).not_to include org_lead_user
        expect(subject.ordered_by_tr_count_users).not_to include team_member
        expect(subject.ordered_by_tr_count_users).not_to include other_team_member
      end
    end
  end
end