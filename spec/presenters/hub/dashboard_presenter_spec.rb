require "rails_helper"

describe Hub::Dashboard::DashboardPresenter do
  subject { described_class.new(user, ability, selected) }
  let(:ability) { Ability.new(user) }
  let(:coalition) { create :coalition }
  let!(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition }
  let(:site) { create :site, name: "Shell Site", parent_organization: oregano_org }
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

  context "with a team member user" do
    let(:user) { create :team_member_user, sites: [site] }
    let(:selected) { "site/#{site.id}" }

    it "presents filter options including only site" do
      expect(subject.filter_options.length).to eq 1
      expect(subject.filter_options.map(&:model).map(&:name)).to eq ["Shell Site"]
    end

    it "selects the correct site" do
      expect(subject.selected_model).to eq site
    end

    context "with an invalid organization selection" do
      let(:selected) { "coalition/#{coalition.id}" }

      it "fails to select" do
        expect(subject.selected_model).to be_nil
      end
    end

    context "clients" do
      let(:other_team_member_same_site) { create :team_member_user, sites: [site] }
      let!(:first_client) {
        create :client, vita_partner: site, filterable_product_year: Rails.configuration.product_year, intake: build(:intake),
                        tax_returns: [build(:gyr_tax_return, assigned_user: user, year: Rails.configuration.product_year)]
      }
      let!(:second_client) {
        create :client, vita_partner: site, filterable_product_year: Rails.configuration.product_year, intake: build(:intake),
                        tax_returns: [build(:gyr_tax_return, assigned_user: user, year: Rails.configuration.product_year)]
      }
      let!(:unassigned_client) {
        create :client, vita_partner: site, filterable_product_year: Rails.configuration.product_year, intake: build(:intake),
                        tax_returns: [build(:gyr_tax_return, assigned_user: other_team_member_same_site, year: Rails.configuration.product_year)]
      }
      it "only includes clients current user is assigned to" do
        expect(subject.clients).to eq [first_client, second_client]
      end
    end
  end
end