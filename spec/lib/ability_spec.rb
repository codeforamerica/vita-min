require "rails_helper"

describe Ability do
  let(:subject) { Ability.new(user) }

  context "a nil user" do
    let(:user) { nil }
    let(:vita_partner) { create :vita_partner }
    let(:client) { create(:client, vita_partner: vita_partner) }
    let(:intake) { create(:intake, vita_partner: vita_partner, client: client) }

    it "cannot manage any client data" do
      expect(subject.can?(:manage, Client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: vita_partner))).to eq false
      expect(subject.can?(:manage, Note.new(client: client))).to eq false
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
      expect(subject.can?(:manage, SystemNote.new)).to eq false
    end
  end

  context "a user and client without an organization" do
    let(:user) { create(:user_with_membership, vita_partner: nil) }
    let(:client) { create(:client, vita_partner: nil) }
    let(:intake) { create(:intake, vita_partner: nil, client: client) }

    it "cannot manage any client data" do
      expect(subject.can?(:manage, client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: nil))).to eq false
      expect(subject.can?(:manage, Note.new(client: client))).to eq false
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
      expect(subject.can?(:manage, SystemNote.new)).to eq false
    end
  end

  context "a user who is a member of a parent organization" do
    let!(:child_org) { create :vita_partner, parent_organization_id: parent_org.id, name: "Child Organization" }
    let!(:parent_org) { create :vita_partner, name: "Parent Organization"}
    let(:user) { create :user, memberships: [build(:membership, vita_partner: parent_org, role: "lead")] }
    let(:managed_user) { create :user, memberships: [build(:membership, vita_partner: child_org)] }
    let(:client) { create :client, vita_partner: child_org }
    let(:intake) { create(:intake, vita_partner: child_org, client: client) }

    it "can manage data in child organizations" do
      expect(subject.can?(:manage, client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, managed_user)).to eq true
      expect(subject.can?(:manage, Note.new(client: client))).to eq true
      expect(subject.can?(:manage, child_org)).to eq true
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
      expect(subject.can?(:manage, SystemNote.new(client: client))).to eq true
    end
  end

  context "a user who is a member of an organization without child organizations" do
    let(:vita_partner) { create(:vita_partner) }
    let(:user) { create :user, memberships: [build(:membership, role: "lead", vita_partner: vita_partner)] }
    let(:managed_user) { create :user, memberships: [build(:membership, vita_partner: vita_partner)] }
    let(:accessible_client) { create(:client, vita_partner: vita_partner) }
    let(:accessible_intake) { create(:intake, vita_partner: vita_partner) }
    let(:other_vita_partner_client) { create(:client, vita_partner: create(:vita_partner)) }
    let(:nil_vita_partner_client) { create(:client, vita_partner: nil) }

    it "can manage data from their own organization" do
      expect(subject.can?(:manage, accessible_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, managed_user)).to eq true
      expect(subject.can?(:manage, Note.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, SystemNote.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, vita_partner)).to eq true
    end

    it "cannot manage data which lack an organization" do
      expect(subject.can?(:manage, nil_vita_partner_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, User.new(memberships: []))).to eq false
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
      expect(subject.can?(:manage, User.new(vita_partner: other_vita_partner_client.vita_partner))).to eq false
      expect(subject.can?(:manage, Note.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, SystemNote.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, other_vita_partner_client.vita_partner)).to eq false
    end
  end

  context "a coalition lead" do
    let(:coalition_member_organization) { create(:vita_partner) }
    let(:intake) { create(:intake, vita_partner: coalition_member_organization) }
    let(:user) { create :user, memberships: [
      build(:membership, vita_partner: create(:vita_partner), role: "lead"),
      build(:membership, vita_partner: coalition_member_organization, role: "lead")
    ] }
    let(:managed_user) { create :user, memberships: [build(:membership, vita_partner: coalition_member_client.vita_partner)] }
    let(:coalition_member_client) { create(:client, intake: intake, vita_partner: coalition_member_organization) }

    it "can manage data from the coalition member organization" do
      expect(subject.can?(:manage, coalition_member_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, managed_user)).to eq true
      expect(subject.can?(:manage, Note.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, SystemNote.new(client: coalition_member_client))).to eq true
    end
  end

  context "as an admin" do
    let(:user) { create(:user, is_admin: true) }
    let(:client) { create(:client, vita_partner: create(:vita_partner)) }

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
      expect(subject.can?(:edit_organization, client)).to eq true
    end
  end
end
