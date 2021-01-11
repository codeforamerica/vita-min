# == Schema Information
#
# Table name: greeter_roles
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe GreeterRole, type: :model do
  describe "required fields" do
    context "with a number of organizations" do
      it "is valid" do
        expect(described_class.new(organizations: create_list(:organization, 2))).to be_valid
      end
    end

    context "with a number of coalitions" do
      it "is valid" do
        expect(described_class.new(coalitions: create_list(:coalition, 2))).to be_valid
      end
    end

    context "without an organization or coalition" do
      it "is valid" do
        expect(described_class.new).to be_valid
      end
    end

    context "with both organizations and coalitions" do
      it "is valid" do
        expect(
          described_class.new(
            organizations: create_list(:organization, 2),
            coalitions: create_list(:coalition, 2)
          )
        ).to be_valid
      end
    end
  end
end
