require "rails_helper"

describe Ability do
  let(:subject) { Ability.new(user) }

  context "a user who is not a member of an organization" do
    let(:user) { create :user, vita_partner: nil }

    it "cannot manage data linked to an organization" do
      client_with_org = create(:client, vita_partner: create(:vita_partner))
      expect(subject.can?(:manage, client_with_org)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client_with_org))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client_with_org))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client_with_org))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client_with_org))).to eq false
      expect(subject.can?(:manage, Document.new(client: client_with_org))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: client_with_org.vita_partner))).to eq false
      expect(subject.can?(:manage, Note.new(client: client_with_org))).to eq false
      expect(subject.can?(:manage, client_with_org.vita_partner)).to eq false
    end

    it "cannot manage data unlinked to an organization" do
      client_without_org = create(:client, vita_partner: nil)
      intake_without_org = create(:intake, vita_partner: nil, client: client_without_org)

      expect(subject.can?(:manage, client_without_org)).to eq false
      expect(subject.can?(:manage, Document.new(intake: intake_without_org))).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: nil))).to eq false
      expect(subject.can?(:manage, Note.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, VitaPartner.new)).to eq false
    end
  end

  context "a user who is a member of an organization" do
    let(:user) { create :user, vita_partner: create(:vita_partner) }

    it "can access data linked to the user's organization" do
      accessible_client = create(:client, vita_partner: user.vita_partner)
      accessible_intake = create(:intake, vita_partner: user.vita_partner)
      expect(subject.can?(:manage, accessible_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, User.new(vita_partner: user.vita_partner))).to eq true
      expect(subject.can?(:manage, Note.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, Document.new(intake: accessible_intake ))).to eq true
      expect(subject.can?(:manage, user.vita_partner)).to eq true
    end

    it "cannot access data not linked to any organization" do
      client_without_org = create(:client, vita_partner: nil)
      expect(subject.can?(:manage, client_without_org)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, Document.new(client: client_without_org))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: nil))).to eq false
      expect(subject.can?(:manage, Note.new(client: client_without_org))).to eq false
    end

    it "cannot access data linked to another organization" do
      other_vita_partner_client = create(:client, vita_partner: create(:vita_partner))
      expect(subject.can?(:manage, other_vita_partner_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: other_vita_partner_client.vita_partner))).to eq false
      expect(subject.can?(:manage, Note.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, other_vita_partner_client.vita_partner)).to eq false
    end
  end

  context "a coalition lead" do
    let(:user) { create :user, vita_partner: create(:vita_partner), supported_organizations: [coalition_member_organization] }
    let(:coalition_member_organization) { create(:vita_partner) }
    let(:intake) { create(:intake, vita_partner: coalition_member_organization) }
    let(:coalition_member_client) { create(:client, intake: intake, vita_partner: coalition_member_organization) }

    it "can access data linked to a coalition member organization" do
      expect(subject.can?(:manage, coalition_member_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: coalition_member_client))).to eq true
      expect(subject.can?(:manage, Document.new(intake: intake))).to eq true
      expect(subject.can?(:manage, User.new(vita_partner: coalition_member_organization))).to eq true
      expect(subject.can?(:manage, Note.new(client: coalition_member_client))).to eq true
    end
  end

  context "as an admin" do
    let(:user) { create(:user, is_admin: true, vita_partner: nil) }
    let(:client) { create(:client, vita_partner: create(:vita_partner)) }

    it "can access all data" do
      expect(subject.can?(:manage, client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: client))).to eq true
      expect(subject.can?(:manage, Document.new(client: client))).to eq true
      expect(subject.can?(:manage, User.new)).to eq true
      expect(subject.can?(:manage, Note.new(client: client))).to eq true
      expect(subject.can?(:manage, VitaPartner.new)).to eq true
    end
  end
end
