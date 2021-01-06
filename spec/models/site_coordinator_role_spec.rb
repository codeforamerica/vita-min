# == Schema Information
#
# Table name: site_coordinator_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_site_coordinator_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe SiteCoordinatorRole, type: :model do
  describe "required fields" do
    context "with a site" do
      it "is valid" do
        site = create(:site)
        expect(described_class.new(site: site)).to be_valid
      end
    end

    context "without a site" do
      it "is invalid" do
        expect(described_class.new).not_to be_valid
      end
    end

    context "with an organization" do
      it "is not valid" do
        organization = create(:organization)
        expect(described_class.new(site: organization)).not_to be_valid
      end
    end
  end
end
