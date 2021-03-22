# == Schema Information
#
# Table name: organization_capacities
#
#  active_client_count :bigint
#  capacity_limit      :integer
#  name                :string
#  vita_partner_id     :bigint           primary key
#
require 'rails_helper'

describe OrganizationCapacity do
  # Ensures that the query for statuses in the view code matches our implementation of clients
  # included in capacity in TaxReturnStatus code.
  describe 'active_client_count' do
    TaxReturnStatus::STATUSES.each do |status|
      context "for #{status} status" do
        let(:organization) { create :organization }
        before do
          create :client_with_status, status: status[0], vita_partner: organization
        end
        if TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY.include?(status[0])
          it "includes client in client count" do
            expect(described_class.find(organization.id).active_client_count).to eq 1
          end
        else
          it "does not include the client in the client count" do
            expect(described_class.find(organization.id).active_client_count).to eq 0
          end
        end
      end
    end
  end

  describe '.with_capacity' do
    context "with a site" do
      let!(:site) { create(:site) }
      it "does not have capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).not_to include(site)
      end
    end

    context "with an organization whose active clients equal capacity" do
      let(:organization) { create :organization, capacity_limit: 1 }
      before do
        create :client_with_status, status: TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY[0], vita_partner: organization
      end

      it "does not have capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).not_to include(organization.id)
      end
    end

    context "with an organization with 0 capacity limit" do
      let!(:organization) { create :organization, capacity_limit: 0 }

      it "does not have capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).not_to include(organization.id)
      end
    end

    context "with an organization whose active clients are below its capacity" do
      let!(:organization) { create :organization, capacity_limit: 2 }
      before do
        create :client_with_status, status: TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY[0], vita_partner: organization
      end

      it "has capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).to include(organization.id)
      end
    end

    context "with an organization whose active clients are above its capacity" do
      let(:organization) { create :organization, capacity_limit: 0 }
      before do
        create :client_with_status, status: TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY[0], vita_partner: organization
      end

      it "does not have capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).not_to include(organization.id)
      end
    end

    context "with an organization whose capacity_limit is nil" do
      let(:organization) { create :organization, capacity_limit: nil }
      before do
        create :client_with_status, status: TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY[0], vita_partner: organization
      end

      it "has capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).to include(organization.id)
      end
    end
  end
end
