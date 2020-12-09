# == Schema Information
#
# Table name: organizations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  coalition_id :bigint
#
# Indexes
#
#  index_organizations_on_coalition_id  (coalition_id)
#  index_organizations_on_name          (name) UNIQUE
#
require "rails_helper"

describe Organization, type: :model do
  describe "#name" do
    context "with an existing organization" do
      before { Organization.create(name: "Orangutan Organization")}

      context "when instantiating a second organization with the same name" do
        it "adds a validation error" do
          organization = Organization.new(name: "Orangutan Organization")

          expect(organization).not_to be_valid
          expect(organization.errors).to include :name
        end
      end
    end
  end
end
