# == Schema Information
#
# Table name: team_member_roles
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
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
  describe "required fields" do
    context "with a site" do
      it "is valid" do
        expect(described_class.new(site: create(:site))).to be_valid
      end
    end

    context "without a site" do
      it "is not valid" do
        expect(described_class.new).not_to be_valid
      end
    end

    context "with a organization" do
      it "is not valid" do
        expect(described_class.new(site: create(:organization))).not_to be_valid
      end
    end
  end
end
