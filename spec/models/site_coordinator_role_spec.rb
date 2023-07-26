# == Schema Information
#
# Table name: site_coordinator_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe SiteCoordinatorRole, type: :model do
  describe "validations" do
    context "with a site" do
      it "is valid" do
        site = create(:site)
        expect(described_class.new(sites: [site])).to be_valid
      end
    end

    context "with sites from multiple parent organizations" do
      it "is not valid" do
        expect(described_class.new(sites: [create(:site), create(:site)])).not_to be_valid
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
        expect { described_class.new(sites: [organization]) }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      end
    end
  end
end
