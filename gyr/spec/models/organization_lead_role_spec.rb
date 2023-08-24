# == Schema Information
#
# Table name: organization_lead_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_organization_lead_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe OrganizationLeadRole, type: :model do
  describe "required fields" do
    context "with an organization" do
      it "is valid" do
        organization = create(:organization)
        expect(described_class.new(organization: organization)).to be_valid
      end
    end

    context "without an organization" do
      it "is not valid" do
        expect(described_class.new).not_to be_valid
      end
    end

    context "with a site" do
      it "is not valid" do
        site = create(:site)
        expect(described_class.new(organization: site)).not_to be_valid
      end
    end
  end
end
