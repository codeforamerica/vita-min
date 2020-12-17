# == Schema Information
#
# Table name: organization_lead_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_organization_lead_roles_on_user_id          (user_id)
#  index_organization_lead_roles_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe OrganizationLeadRole, type: :model do
  describe "required fields" do
    context "with organization and no user" do
      it "is not valid" do
        expect(described_class.new(organization: create(:organization))).not_to be_valid
      end
    end

    context "with user and organization" do
      it "is valid" do
        organization = create(:organization)
        user = create(:user)
        expect(described_class.new(user: user, organization: organization)).to be_valid
      end
    end

    context "with a user and no organization" do
      it "is not valid" do
        expect(described_class.new(user: create(:user))).not_to be_valid
      end
    end

    context "with user and a site" do
      it "is not valid" do
        site = create(:site)
        expect(described_class.new(user: create(:user), organization: site)).not_to be_valid
      end
    end
  end
end
