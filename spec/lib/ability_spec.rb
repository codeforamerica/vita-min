require "rails_helper"

describe Ability do
  let (:subject) { Ability.new(user) }
  context "as a beta tester" do
    let(:user) { create :beta_tester }
    it "can manage clients" do
      expect(subject.can?(:manage, Client.new)).to eq true
    end
  end

  context "as a non-beta tester" do
    let(:user) { create :user }
    it "cannot manage clients" do
      expect(subject.can?(:manage, Client.new)).to eq false
    end
  end
end