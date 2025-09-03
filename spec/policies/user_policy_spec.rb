require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let!(:policy) { described_class }
  let!(:admin) { create(:admin_user) }

  let(:coalition) { create :coalition }
  let(:organization) { create :organization, coalition: coalition }
  let(:site) { create :site, parent_organization: organization }

  let!(:organization_lead) { create :organization_lead_user, organization: organization }
  let!(:site_coordinator) { create :site_coordinator_user, sites: [site] }
  let!(:team_member) { create :team_member_user, sites: [site] }
  let!(:other_site_team_member) { create :team_member_user }

  permissions ".scope" do
    it "only returns the accessible user and current user" do
      expect(Pundit.policy_scope!(admin, User)).to eq([admin, organization_lead, site_coordinator, team_member, other_site_team_member])
      expect(Pundit.policy_scope!(organization_lead, User)).to eq([organization_lead, site_coordinator, team_member])
      expect(Pundit.policy_scope!(team_member, User)).to eq([organization_lead, site_coordinator, team_member])
      expect(Pundit.policy_scope!(site_coordinator, User)).to eq([organization_lead, site_coordinator, team_member])
      expect(Pundit.policy_scope!(team_member, User)).not_to include(other_site_team_member)
      expect(Pundit.policy_scope!(other_site_team_member, User)).to eq([other_site_team_member])
    end
  end

  permissions :index? do
    it "allows access" do
      expect(policy).to permit(admin, User)
      expect(policy).to permit(organization_lead, User)
      expect(policy).to permit(site_coordinator, User)
      expect(policy).to permit(team_member, User)
      expect(policy).to permit(other_site_team_member, User)
    end
  end

  permissions :profile? do
    context "when the record is the current user" do
      it "permits access" do
        expect(policy).to permit(admin, admin)
        expect(policy).to permit(organization_lead, organization_lead)
        expect(policy).to permit(site_coordinator, site_coordinator)
        expect(policy).to permit(team_member, team_member)
        expect(policy).to permit(other_site_team_member, other_site_team_member)
      end
    end

    context "when the record is NOT the current user" do
      it "forbids access" do
        expect(policy).not_to permit(admin, organization_lead)
        expect(policy).not_to permit(organization_lead, site_coordinator)
        expect(policy).not_to permit(site_coordinator, team_member)
      end
    end
  end

  permissions :destroy?, :update_role?, :edit_role? do
    context "when user is admin" do
      it "can destroy/update_role/edit_role any user" do
        expect(policy).to permit(admin, admin)
        expect(policy).to permit(admin, organization_lead)
        expect(policy).to permit(admin, site_coordinator)
        expect(policy).to permit(admin, team_member)
        expect(policy).to permit(admin, other_site_team_member)
      end
    end

    context "when user is an org lead" do
      it "can destroy/update_role/edit_role any accessible user" do
        expect(policy).to permit(organization_lead, organization_lead)
        expect(policy).to permit(organization_lead, site_coordinator)
        expect(policy).to permit(organization_lead, team_member)
      end

      it "canNOT destroy/update_role/edit_role inaccessible users" do
        expect(policy).not_to permit(organization_lead, admin)
        expect(policy).not_to permit(organization_lead, other_site_team_member)
      end
    end

    context "when user is not an org lead or admin" do
      it "cannot destroy/update_role/edit_role any users" do
        expect(policy).not_to permit(other_site_team_member, organization_lead)
        expect(policy).not_to permit(other_site_team_member, site_coordinator)
        expect(policy).not_to permit(other_site_team_member, team_member)
        expect(policy).not_to permit(other_site_team_member, admin)
        expect(policy).not_to permit(other_site_team_member, other_site_team_member)
      end
    end
  end

  permissions :edit?, :update? do
    context "when the record is the current user" do
      it "permits edit/update access" do
        expect(policy).to permit(admin, admin)
        expect(policy).to permit(organization_lead, organization_lead)
        expect(policy).to permit(site_coordinator, site_coordinator)
        expect(policy).to permit(team_member, team_member)
        expect(policy).to permit(other_site_team_member, other_site_team_member)
      end
    end

    context "when they are an admin or org lead" do
      it "permits edit/update access when user is in scope" do
        expect(policy).to permit(admin, other_site_team_member)
        expect(policy).to permit(organization_lead, site_coordinator)
        expect(policy).to permit(organization_lead, team_member)
        expect(policy).not_to permit(other_site_team_member, organization_lead)
      end
    end

    context "when they are a site coordinator" do
      it "permits edit/update access to site coordinators and team members that belong to user's sites" do
        expect(policy).to permit(site_coordinator, site_coordinator)
        expect(policy).to permit(site_coordinator, team_member)
        expect(policy).not_to permit(site_coordinator, other_site_team_member)
        expect(policy).not_to permit(site_coordinator, organization_lead)
      end
    end
  end

  permissions :unlock?, :resend_invitation?, :suspend?, :unsuspend?  do
    context "when they are an admin or org lead" do
      it "permits unlock/resend_invitation/suspend/unsuspend access when user is in scope" do
        expect(policy).to permit(admin, other_site_team_member)
        expect(policy).to permit(organization_lead, site_coordinator)
        expect(policy).to permit(organization_lead, team_member)
        expect(policy).not_to permit(other_site_team_member, organization_lead)
      end
    end

    context "when they are a site coordinator" do
      it "permits unlock/resend_invitation/suspend/unsuspend access to site coordinators and team members that belong to user's sites" do
        expect(policy).to permit(site_coordinator, site_coordinator)
        expect(policy).to permit(site_coordinator, team_member)
        expect(policy).not_to permit(site_coordinator, other_site_team_member)
        expect(policy).not_to permit(site_coordinator, organization_lead)
      end
    end
  end
end
