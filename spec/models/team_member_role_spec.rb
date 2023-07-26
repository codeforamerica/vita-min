# == Schema Information
#
# Table name: team_member_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe TeamMemberRole, type: :model do
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
