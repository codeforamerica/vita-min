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
end
