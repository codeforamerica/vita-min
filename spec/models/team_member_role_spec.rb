# == Schema Information
#
# Table name: team_member_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint
#
# Indexes
#
#  index_team_member_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe TeamMemberRole, type: :model do
  describe '#sites' do
    it "returns the old associated site if this record hasn't been migrated to join table land" do
      site = create(:site)
      role = described_class.new(vita_partner_id: site.id)
      expect(role.sites).to eq([site])
    end
  end

  describe "validations" do
    context "with a site" do
      it "is valid" do
        expect(described_class.new(sites: [create(:site)])).to be_valid
      end
    end

    context "with sites from multiple parent organizations" do
      it "is not valid" do
        expect(described_class.new(sites: [create(:site), create(:site)])).not_to be_valid
      end
    end

    context "without a site" do
      it "is not valid" do
        expect(described_class.new).not_to be_valid
      end
    end

    context "with a organization" do
      it "is not allowed" do
        expect { described_class.new(sites: [create(:organization)]) }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      end
    end
  end
end
