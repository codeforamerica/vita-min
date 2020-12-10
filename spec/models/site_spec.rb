# == Schema Information
#
# Table name: sites
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_sites_on_organization_id           (organization_id)
#  index_sites_on_organization_id_and_name  (organization_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "rails_helper"

describe Site, type: :model do
  let(:organization) { create :organization }
  describe "#name" do
    context "with an existing site at the same organization" do
      before { Site.create(name: "Para Site", organization: organization) }

      context "when instantiating a second site at the same organization with the same name" do
        it "adds a validation error" do
          site = Site.new(name: "Para Site", organization: organization)

          expect(site).not_to be_valid
          expect(site.errors).to include :name
        end
      end
    end
  end
end
