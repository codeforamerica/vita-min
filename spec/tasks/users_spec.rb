require "rails_helper"

describe "users:suspend_non_admins" do
  include_context "rake"

  let(:original_suspended_at) { 1.month.ago.change(usec: 0) }
  let!(:team_member) { create :team_member_user }
  let!(:site_coordinator) { create :site_coordinator_user }
  let!(:admin) { create :admin_user }
  let!(:suspended_team_member) { create :team_member_user, suspended_at: original_suspended_at }
  let!(:suspended_admin) { create :admin_user, suspended_at: original_suspended_at }
  let!(:team_member_tax_return) { create :gyr_tax_return, assigned_user: team_member }
  let!(:site_coordinator_tax_return) { create :gyr_tax_return, assigned_user: site_coordinator }
  let!(:admin_tax_return) { create :gyr_tax_return, assigned_user: admin }
  let!(:suspended_team_member_tax_return) { create :gyr_tax_return, assigned_user: suspended_team_member }
  let!(:suspended_admin_tax_return) { create :gyr_tax_return, assigned_user: suspended_admin }

  it "suspends non admin users and unassigns their tax returns" do
    task.invoke

    expect(team_member.reload).to be_suspended
    expect(site_coordinator.reload).to be_suspended
    expect(team_member_tax_return.reload.assigned_user).to be_nil
    expect(site_coordinator_tax_return.reload.assigned_user).to be_nil
  end

  it "leaves active admins and their tax returns alone" do
    task.invoke

    expect(admin.reload).to be_active
    expect(admin_tax_return.reload.assigned_user).to eq admin
  end

  it "unassigns tax returns from already suspended users without changing when they were suspended" do
    task.invoke

    expect(suspended_team_member_tax_return.reload.assigned_user).to be_nil
    expect(suspended_admin_tax_return.reload.assigned_user).to be_nil
    expect(suspended_team_member.reload.suspended_at).to eq original_suspended_at
    expect(suspended_admin.reload.suspended_at).to eq original_suspended_at
  end
end
