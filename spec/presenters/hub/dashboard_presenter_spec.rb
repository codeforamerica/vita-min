require "rails_helper"

describe Hub::Dashboard::DashboardPresenter do
  subject { described_class.new(user, ability, selected) }
  let(:ability) { Ability.new(user) }
  let(:coalition) { create :coalition }
  let!(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition }
  let!(:orangutan_organization) { create :organization, name: "Orangutan Organization", coalition: coalition }

  context "with a coalition lead user" do
    let(:user) { create :coalition_lead_user, coalition: coalition }
    let(:selected) { "coalition/#{coalition.id}" }

    it "presents filter options including the coalition and all organizations in the correct order" do
      expect(subject.filter_options.length).to eq 3
      expect(subject.filter_options.map(&:model).map(&:name)).to eq [coalition.name, "Orangutan Organization", "Oregano Org"]
    end

    it "selects the correct coalition" do
      expect(subject.selected_model).to eq coalition
    end

    context "with an organization selected" do
      let(:selected) { "organization/#{orangutan_organization.id}" }
      it "selects the correct coalition" do
        expect(subject.selected_model).to eq orangutan_organization
      end
    end
  end

  context "with an organization lead user" do
    let(:user) { create :organization_lead_user, organization: oregano_org }
    let(:selected) { "organization/#{oregano_org.id}" }

    it "presents filter options including only organization" do
      expect(subject.filter_options.length).to eq 1
      expect(subject.filter_options.map(&:model).map(&:name)).to eq ["Oregano Org"]
    end

    it "selects the correct organization" do
      expect(subject.selected_model).to eq oregano_org
    end

    context "with an invalid organization selection" do
      let(:selected) { "coalition/#{coalition.id}" }

      it "fails to select" do
        expect(subject.selected_model).to be_nil
      end
    end
  end
end