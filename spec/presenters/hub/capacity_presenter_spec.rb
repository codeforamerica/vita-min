require "rails_helper"

describe Hub::Dashboard::CapacityPresenter do
  subject { described_class.new(selected) }
  let(:coalition) { create :coalition }
  let!(:oregano_org) { create :organization, name: "Oregano Org", coalition: coalition, capacity_limit: 10 }
  let!(:orangutan_organization) { create :organization, name: "Orangutan Organization", coalition: coalition, capacity_limit: 5 }
  before do
    allow(oregano_org).to receive(:active_client_count).and_return(7)
    allow(orangutan_organization).to receive(:active_client_count).and_return(6)
  end

  context "with a selected coalition" do
    let(:selected) { coalition }

    it "Accurately displays the capacity" do
      expect(subject.capacity).to eq([orangutan_organization, oregano_org])
      expect(subject.capacity_count).to eq(2)
    end
  end

  context "with a selected organization" do
    let(:selected) { oregano_org }

    it "Accurately displays the capacity" do
      expect(subject.capacity).to eq([oregano_org])
      expect(subject.capacity_count).to eq(1)
    end
  end
end