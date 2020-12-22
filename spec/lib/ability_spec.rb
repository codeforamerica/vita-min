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
    let(:organization) { create :organization }
    let!(:site) { create :site, parent_organization: organization }
    let(:user) { create :user, role: create(:organization_lead_role, organization: organization) }
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

  context "an organization lead" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }
    let(:accessible_client) { create(:client, vita_partner: organization) }
    let(:accessible_intake) { create(:intake, vita_partner: organization) }
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
      expect(subject.can?(:manage, organization)).to eq false
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
    let(:coalition_member_organization) { create(:vita_partner) }
    let(:intake) { create(:intake, vita_partner: coalition_member_organization) }
    let(:user) { create :user, supported_organizations: [coalition_member_organization] }
    let(:coalition_member_client) { create(:client, intake: intake, vita_partner: coalition_member_organization) }

    it "can manage data from the coalition member organization" do
      expect(subject.can?(:manage, coalition_member_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, Note.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, SystemNote.new(client: coalition_member_client))).to eq true
    end
  end

  context "as an admin" do
    let(:user) { create(:user, is_admin: true) }
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

  context "as a client support user" do
    let!(:user) { create :user, is_client_support: true }
    let(:client_1) { create(:client, vita_partner: create(:organization)) }
    let(:client_2) { create(:client, vita_partner: create(:organization)) }

    it "can see all clients from any organization" do
      expect(subject.can?(:read, client_1)).to eq true
      expect(subject.can?(:read, client_2)).to eq true
    end

    it "can not manage any client" do
      expect(subject.can?(:manage, client_1)).to eq false
      expect(subject.can?(:manage, client_2)).to eq false
    end
  end

  context "User" do
    let(:organization) { create :organization }

    context "when current user is the User" do
      let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }
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
      let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }
      let(:target_user) { create :user }

      it "can not manage" do
        expect(subject.can?(:manage, target_user)).to eq false
      end
    end

    context "for any other user" do
      let(:user) { create(:user) }
      let(:target_user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

      it "can not manage" do
        expect(subject.can?(:manage, target_user)).to eq false
      end
    end
  end
end
