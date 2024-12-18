require "rails_helper"

describe Hub::Dashboard::ServiceLevelAgreementsNotificationsPresenter do
  subject { described_class.new(clients, selected_orgs_and_sites) }

  let(:coalition) { create :coalition }
  let(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition }
  let(:orangutan_organization) { create :organization, name: "Orangutan Organization", coalition: coalition }
  let(:selected_orgs_and_sites) { [oregano_org, orangutan_organization] }
  let(:clients) { Client.all }

  before do
    create :client, vita_partner: oregano_org, last_outgoing_communication_at: 5.business_days.ago, intake: (build :intake), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]
    create :client, vita_partner: oregano_org, last_outgoing_communication_at: 7.business_days.ago, intake: (build :intake), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]
    create :client, vita_partner: orangutan_organization, last_outgoing_communication_at: 5.business_days.ago, intake: (build :intake), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]
    create :client, vita_partner: orangutan_organization, last_outgoing_communication_at: 8.business_days.ago, intake: (build :intake), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]
    create :client, vita_partner: orangutan_organization, last_outgoing_communication_at: 9.business_days.ago, intake: (build :intake), tax_returns: [build(:gyr_tax_return, :prep_ready_for_prep)]
  end

  describe "#approaching_sla_clients" do
    it "returns clients whose last communication was between 4 and 6 business days ago, and have active returns" do
      expect(subject.approaching_sla_clients_count).to eq 2
    end
  end

  describe "#breached_sla_clients" do
    it "returns clients whose last communication was more than 6 business days ago and have active returns" do
      expect(subject.breached_sla_clients_count).to eq 3
    end
  end

  describe "#approaching_sla_client_ids" do
    it "returns the ids of organizations with approaching SLA clients" do
      expect(subject.approaching_sla_client_ids).to contain_exactly(oregano_org.id, orangutan_organization.id)
    end
  end

  describe "#breached_sla_client_ids" do
    it "returns the ids of organizations with breached SLA clients" do
      expect(subject.breached_sla_client_ids).to contain_exactly(oregano_org.id, orangutan_organization.id)
    end
  end
end
