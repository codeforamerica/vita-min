require "rails_helper"

describe Ability do
  let(:subject) { Ability.new(user) }

  context "a nil user" do
    let(:user) { nil }
    let(:organization) { create :organization }
    let(:client) { create(:client, vita_partner: organization) }
    let(:intake) { create(:intake, vita_partner: organization, client: client) }

    it "cannot manage any client data" do
      expect(subject.can?(:manage, Client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, User)).to eq false
      expect(subject.can?(:manage, Note.new(client: client))).to eq false
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
      expect(subject.can?(:manage, SystemNote.new)).to eq false
    end
  end

  context "a user and client without an organization" do
    let(:user) { create(:user) }
    let(:client) { create(:client, vita_partner: nil) }
    let(:intake) { create(:intake, vita_partner: nil, client: client) }

    it "cannot manage any client data" do
      expect(subject.can?(:manage, client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, User.new)).to eq false
      expect(subject.can?(:manage, Note.new(client: client))).to eq false
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
      expect(subject.can?(:manage, SystemNote.new)).to eq false
    end
  end

  context "a user who is an org lead at an organization that has some sites" do
    let(:user) { create :organization_lead_user }
    let!(:site) { create :site, parent_organization: user.role.organization }
    let(:intake) { create(:intake, vita_partner: site, client: (create :client, vita_partner: site)) }
    let(:client) { intake.client }

    it "can manage clients assigned to sites but not manage the org itself" do
      expect(subject.can?(:manage, client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, Note.new(client: client))).to eq true
      expect(subject.can?(:manage, SystemNote.new(client: client))).to eq true
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
      expect(subject.can?(:manage, site)).to eq false
    end
  end

  context "a team member" do
    let(:user) { create :team_member_user }
    let(:accessible_client) { create(:client, vita_partner: user.role.site) }
    let(:other_vita_partner_client) { create(:client, vita_partner: create(:organization)) }

    it "can manage their own data" do
      expect(subject.can?(:manage, user)).to eq true
    end

    it "can view clients from their own site" do
      expect(subject.can?(:read, accessible_client)).to eq true
    end

    it "cannot view clients from another group" do
      expect(subject.can?(:read, other_vita_partner_client)).to eq false
    end

    it "can manage data from clients in their site" do
      expect(subject.can?(:manage, accessible_client)).to eq true
    end

    it "cannot manage data from clients in other sites" do
      expect(subject.can?(:manage, other_vita_partner_client)).to eq false
    end
  end

  context "a site coordinator" do
    let(:user) { create :site_coordinator_user }
    let(:accessible_client) { create(:client, vita_partner: user.role.site) }
    let(:other_vita_partner_client) { create(:client, vita_partner: create(:site)) }

    it "can manage their own data" do
      expect(subject.can?(:manage, user)).to eq true
    end

    it "can view clients from their own site" do
      expect(subject.can?(:read, accessible_client)).to eq true
    end

    it "can not view clients from other sites" do
      expect(subject.can?(:read, other_vita_partner_client)).to eq false
    end

    it "can manage data from clients in their site" do
      expect(subject.can?(:manage, accessible_client)).to eq true
    end

    it "cannot manage data from clients in other sites" do
      expect(subject.can?(:manage, other_vita_partner_client)).to eq false
    end
  end

  context "an organization lead" do
    let(:user) { create :organization_lead_user }
    let(:accessible_client) { create(:client, vita_partner: user.role.organization) }
    let(:accessible_intake) { create(:intake, vita_partner: user.role.organization) }
    let(:other_vita_partner_client) { create(:client, vita_partner: create(:organization)) }
    let(:nil_vita_partner_client) { create(:client, vita_partner: nil) }

    it "can manage data from their own organization's clients but not the org itself" do
      expect(subject.can?(:manage, accessible_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, Note.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, SystemNote.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, user.role.organization)).to eq false
    end

    it "cannot manage data which lack an organization" do
      expect(subject.can?(:manage, nil_vita_partner_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, User.new)).to eq false
      expect(subject.can?(:manage, Note.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, SystemNote.new(client: nil_vita_partner_client))).to eq false
    end

    it "cannot manage data from another organization" do
      expect(subject.can?(:manage, other_vita_partner_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, User.new)).to eq false
      expect(subject.can?(:manage, Note.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, SystemNote.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, other_vita_partner_client.vita_partner)).to eq false
    end
  end

  context "a coalition lead" do
    let(:coalition) { create :coalition }
    let!(:organization) { create :organization, coalition: coalition }
    let!(:site) { create :site, parent_organization: organization }
    let(:user) { create :coalition_lead_user, role: create(:coalition_lead_role, coalition: coalition) }
    let(:coalition_org_client) { create(:client, vita_partner: organization) }
    let(:coalition_site_client) { create(:client, vita_partner: site) }
    let(:other_client) { create(:client, vita_partner: create(:vita_partner)) }

    it "can manage their own data" do
      expect(subject.can?(:manage, user)).to eq true
    end

    it "can view clients from groups in their coalition" do
      expect(subject.can?(:read, coalition_org_client)).to eq true
      expect(subject.can?(:read, coalition_site_client)).to eq true
    end

    it "cannot view clients from another coalition" do
      expect(subject.can?(:read, other_client)).to eq false
    end

    it "can manage data from clients in their coalition" do
      expect(subject.can?(:manage, coalition_org_client)).to eq true
      expect(subject.can?(:manage, coalition_site_client)).to eq true
    end

    it "cannot manage data from clients in other groups" do
      expect(subject.can?(:manage, other_client)).to eq false
    end
  end

  context "as an admin" do
    let(:user) { create(:user, role: create(:admin_role)) }
    let(:client) { create(:client, vita_partner: create(:organization)) }

    it "can manage any data" do
      expect(subject.can?(:manage, client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, Document.new(client: client))).to eq true
      expect(subject.can?(:manage, User.new)).to eq true
      expect(subject.can?(:manage, Note.new(client: client))).to eq true
      expect(subject.can?(:manage, VitaPartner.new)).to eq true
      expect(subject.can?(:manage, SystemNote.new)).to eq true
    end
  end

  context "User" do
    context "when current user is the User" do
      let(:user) { create :organization_lead_user }
      let(:target_user) { user }

      it "can manage" do
        expect(subject.can?(:manage, target_user)).to eq true
      end
    end

    context "when current user is an admin" do
      let(:user) { build(:admin_user) }
      let(:target_user) { build(:user) }

      it "can manage" do
        expect(subject.can?(:manage, target_user)).to eq true
      end
    end

    context "when current user is in the same org" do
      let(:user) { create :organization_lead_user  }
      let(:target_user) { create :organization_lead_user, organization: user.role.organization }

      it "can not manage" do
        expect(subject.can?(:manage, target_user)).to eq false
      end
    end

    context "for any other user" do
      let(:user) { create(:user) }
      let(:target_user) { create :organization_lead_user }

      it "can not manage" do
        expect(subject.can?(:manage, target_user)).to eq false
      end
    end
  end

  context "Managing roles" do
    context "AdminRole" do
      let(:target_role) { AdminRole }
      context "current user is an admin" do
        let(:user) { build(:admin_user) }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "otherwise" do
        let(:user) { build(:coalition_lead_user) }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end
    end

    context "CoalitionLeadRole" do
      let(:target_role) { create :coalition_lead_role }
      let(:coalition) { target_role.coalition }

      context "current user is coalition lead in the same coalition" do
        let(:user) { create :coalition_lead_user, coalition: coalition }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is coalition lead in a different coalition" do
        let(:user) { create :coalition_lead_user }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "otherwise" do
        let(:user) { create :organization_lead_user, organization: build(:organization, coalition: coalition) }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end
    end

    context "OrganizationLeadRole" do
      let(:target_role) { create :organization_lead_role }
      let(:organization) { target_role.organization }

      context "current user is coalition lead in a parent coalition" do
        let(:coalition) { create :coalition, organizations: [organization] }
        let(:user) { create :coalition_lead_user, coalition: coalition }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is coalition lead in a different coalition" do
        let(:user) { create :coalition_lead_user }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "current user is organization lead in the same organization" do
        let(:user) { create :organization_lead_user, organization: organization }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is organization lead in another organization" do
        let(:user) { create :organization_lead_user }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "anyone else" do
        let(:user) { create :site_coordinator_user, site: create(:site, parent_organization: organization) }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end
    end

    context "SiteCoordinatorRole" do
      let(:coalition) { create :coalition }
      let(:organization) { create :organization, coalition: coalition }
      let(:another_organization) { create :organization, coalition: coalition }
      let(:site) { create(:site, parent_organization: organization) }
      let(:another_site) { create(:site, parent_organization: organization)}
      let(:target_role) { create :site_coordinator_role, site: site }

      context "current user is coalition lead in the site's coalition" do
        let(:user) { create :coalition_lead_user, coalition: coalition }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is coalition lead in a different coalition" do
        let(:user) { create :coalition_lead_user }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "current user is organization lead in the site's parent organization" do
        let(:user) { create :organization_lead_user, organization: organization }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is organization lead in another organization" do
        let(:user) { create :organization_lead_user, organization: another_organization }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "current user is site coordinator in the same site" do
        let(:user) { create :site_coordinator_user, site: site }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is site coordinator in another site" do
        let(:user) { create :site_coordinator_user, site: another_site }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "anyone else" do
        let(:user) { create :team_member_user, site: site }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end
    end

    context "TeamMemberRole" do
      let(:coalition) { create :coalition }
      let(:organization) { create :organization, coalition: coalition }
      let(:another_organization) { create :organization, coalition: coalition }
      let(:site) { create(:site, parent_organization: organization) }
      let(:another_site) { create(:site, parent_organization: organization)}
      let(:target_role) { create :team_member_role, site: site }

      context "current user is coalition lead in the site's coalition" do
        let(:user) { create :coalition_lead_user, coalition: coalition }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is coalition lead in a different coalition" do
        let(:user) { create :coalition_lead_user }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "current user is organization lead in the site's parent organization" do
        let(:user) { create :organization_lead_user, organization: organization }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is organization lead in another organization" do
        let(:user) { create :organization_lead_user, organization: another_organization }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "current user is site coordinator in the same site" do
        let(:user) { create :site_coordinator_user, site: site }

        it "can manage" do
          expect(subject.can?(:manage, target_role)).to eq true
        end
      end

      context "current user is site coordinator in another site" do
        let(:user) { create :site_coordinator_user, site: another_site }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end

      context "anyone else" do
        let(:user) { create :team_member_user, site: site }

        it "cannot manage" do
          expect(subject.can?(:manage, target_role)).to eq false
        end
      end
    end
  end
end
