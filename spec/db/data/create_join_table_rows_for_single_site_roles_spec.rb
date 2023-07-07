require "rails_helper"
require_relative "../../../db/data/20230706184950_create_join_table_rows_for_single_site_roles"

describe "CreateJoinTableRowsForSingleSiteRoles" do
  let(:site) { create(:site) }
  let(:second_site) { create(:site) }

  let!(:team_member) { create :user, role: create(:team_member_role, sites: [site]) }
  let!(:legacy_team_member) { create :user, role: create(:team_member_role, legacy_vita_partner: site, sites: []) }
  let!(:another_team_member) { create :user, role: create(:team_member_role, sites: [second_site]) }
  let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, sites: [site]) }
  let!(:legacy_site_coordinator) { create :user, role: create(:site_coordinator_role, legacy_vita_partner: site, sites: []) }

  it "creates join table entries for every vita_partner_id on these roles and clears out the singular vita_partner_id" do
    expect(legacy_team_member.reload.role.team_member_roles_vita_partners.map(&:vita_partner)).to eq([])
    expect(legacy_site_coordinator.reload.role.site_coordinator_roles_vita_partners.map(&:vita_partner)).to eq([])

    expect(team_member.reload.role.team_member_roles_vita_partners.map(&:vita_partner)).to eq([site])
    expect(another_team_member.reload.role.team_member_roles_vita_partners.map(&:vita_partner)).to eq([second_site])
    expect(site_coordinator.reload.role.site_coordinator_roles_vita_partners.map(&:vita_partner)).to eq([site])

    CreateJoinTableRowsForSingleSiteRoles.new.up

    # legacy rows gain new join table entry
    expect(legacy_team_member.reload.role.team_member_roles_vita_partners.map(&:vita_partner)).to eq([site])
    expect(legacy_site_coordinator.reload.role.site_coordinator_roles_vita_partners.map(&:vita_partner)).to eq([site])

    # new-style roles stay the same
    expect(team_member.reload.role.team_member_roles_vita_partners.map(&:vita_partner)).to eq([site])
    expect(another_team_member.reload.role.team_member_roles_vita_partners.map(&:vita_partner)).to eq([second_site])
    expect(site_coordinator.reload.role.site_coordinator_roles_vita_partners.map(&:vita_partner)).to eq([site])

    # legacy foreign keys removed
    expect(SiteCoordinatorRole.where.not(vita_partner_id: nil).count).to eq(0)
    expect(TeamMemberRole.where.not(vita_partner_id: nil).count).to eq(0)
  end
end
