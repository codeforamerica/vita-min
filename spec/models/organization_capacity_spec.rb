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
  let(:in_range_states) { TaxReturnStateMachine.states.map(&:to_sym) - TaxReturnStateMachine::EXCLUDED_FROM_CAPACITY }

  # Ensures that the query for statuses in the view code matches our implementation of clients
  # included in capacity in TaxReturnStatus code.
  describe 'active_client_count' do
    TaxReturnStateMachine.states.map(&:to_sym).each do |state|
      context "for #{state} tax return state" do
        let(:organization) { create :organization }
        before do
          create :client_with_tax_return_state, state: state, vita_partner: organization,intake: create(:intake)
        end

        unless TaxReturnStateMachine::EXCLUDED_FROM_CAPACITY.include?(state)
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

    context "when intake associated with client is archived" do
      let(:organization) { create :organization }
      before do
        client = create :client_with_tax_return_state, state: :prep_ready_for_prep, vita_partner: organization
        create :archived_2021_gyr_intake, client: client
      end

      it "does not include the client in the client count" do
        expect(described_class.find(organization.id).active_client_count).to eq 0
      end
    end

    context "when intake associated with client is not archived" do
      let(:organization) { create :organization }
      let(:intake) { create :intake }
      before do
        create :client_with_tax_return_state, state: :prep_ready_for_prep, vita_partner: organization, intake: intake
      end

      it "does include the client in the client count" do
        expect(described_class.find(organization.id).active_client_count).to eq 1
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
        create :client_with_tax_return_state, state: in_range_states[0], vita_partner: organization, intake: create(:intake)
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
        create :client_with_tax_return_state, state: in_range_states[0], vita_partner: organization
      end

      it "has capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).to include(organization.id)
      end
    end

    context "with an organization whose active clients are above its capacity" do
      let(:organization) { create :organization, capacity_limit: 0 }
      before do
        create :client_with_tax_return_state, state: in_range_states[0], vita_partner: organization
      end

      it "does not have capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).not_to include(organization.id)
      end
    end

    context "with an organization whose capacity_limit is nil" do
      let(:organization) { create :organization, capacity_limit: nil }
      before do
        create :client_with_tax_return_state, state: in_range_states[0], vita_partner: organization
      end

      it "has capacity" do
        expect(described_class.with_capacity.pluck(:vita_partner_id)).to include(organization.id)
      end
    end
  end
end
