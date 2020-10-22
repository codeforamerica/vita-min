require "rails_helper"

describe Ability do
  let (:subject) { Ability.new(user) }

  context "a beta tester who is a member of one organization" do
    let(:user) { create :beta_tester, vita_partner: create(:vita_partner) }
    let(:accessible_client) { create(:client, vita_partner: user.vita_partner) }
    let(:other_vita_partner_client) { create(:client, vita_partner: create(:vita_partner)) }
    let(:nil_vita_partner_client) { create(:client, vita_partner: nil) }

    it "can access client data from their own organization" do
      expect(subject.can?(:manage, accessible_client)).to eq true
      expect(subject.can?(:manage, IncomingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, IncomingEmail.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, Document.new(client: accessible_client))).to eq true
      expect(subject.can?(:manage, User.new(vita_partner: user.vita_partner))).to eq true
      expect(subject.can?(:manage, Note.new(client: accessible_client))).to eq true
    end

    it "cannot access client data which lack an organization" do
      expect(subject.can?(:manage, nil_vita_partner_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: nil_vita_partner_client))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: nil))).to eq false
      expect(subject.can?(:manage, Note.new(client: nil_vita_partner_client))).to eq false
    end

    it "cannot access client data from another organization" do
      expect(subject.can?(:manage, other_vita_partner_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: other_vita_partner_client))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: other_vita_partner_client.vita_partner))).to eq false
      expect(subject.can?(:manage, Note.new(client: other_vita_partner_client))).to eq false
    end
  end

  context "as a non-beta tester" do
    let(:user) { create :user }
    let(:accessible_client) { create(:client, vita_partner: user.vita_partner) }

    it "cannot manage any case management resources" do
      expect(subject.can?(:manage, accessible_client)).to eq false
      expect(subject.can?(:manage, IncomingTextMessage.new(client: accessible_client))).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new(client: accessible_client))).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new(client: accessible_client))).to eq false
      expect(subject.can?(:manage, IncomingEmail.new(client: accessible_client))).to eq false
      expect(subject.can?(:manage, Document.new(client: accessible_client))).to eq false
      expect(subject.can?(:manage, User.new(vita_partner: user.vita_partner))).to eq false
      expect(subject.can?(:manage, Note.new(client: accessible_client))).to eq false
    end
  end
end