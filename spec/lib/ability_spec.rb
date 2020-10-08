require "rails_helper"

describe Ability do
  let (:subject) { Ability.new(user) }
  context "as a beta tester" do
    let(:user) { create :beta_tester }
    it "can manage all case management resources" do
      expect(subject.can?(:manage, IncomingTextMessage.new)).to eq true
      expect(subject.can?(:manage, OutgoingTextMessage.new)).to eq true
      expect(subject.can?(:manage, OutgoingEmail.new)).to eq true
      expect(subject.can?(:manage, IncomingEmail.new)).to eq true
      expect(subject.can?(:manage, Client.new)).to eq true
      expect(subject.can?(:manage, Document.new)).to eq true
      expect(subject.can?(:manage, User.new)).to eq true
      expect(subject.can?(:manage, Note.new)).to eq true
    end
  end

  context "as a non-beta tester" do
    let(:user) { create :user }
    it "cannot manage any case management resources" do
      expect(subject.can?(:manage, IncomingTextMessage.new)).to eq false
      expect(subject.can?(:manage, OutgoingTextMessage.new)).to eq false
      expect(subject.can?(:manage, OutgoingEmail.new)).to eq false
      expect(subject.can?(:manage, IncomingEmail.new)).to eq false
      expect(subject.can?(:manage, Client.new)).to eq false
      expect(subject.can?(:manage, Document.new)).to eq false
      expect(subject.can?(:manage, User.new)).to eq false
      expect(subject.can?(:manage, Note.new)).to eq false
    end
  end
end