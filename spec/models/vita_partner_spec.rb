# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  allows_greeters            :boolean
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  org_level_routing_enabled  :boolean          default(TRUE)
#  processes_ctc              :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
#  type                       :string           not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  coalition_id               :bigint
#  parent_organization_id     :bigint
#
# Indexes
#
#  index_vita_partners_on_coalition_id               (coalition_id)
#  index_vita_partners_on_parent_name_and_coalition  (parent_organization_id,name,coalition_id) UNIQUE
#  index_vita_partners_on_parent_organization_id     (parent_organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (coalition_id => coalitions.id)
#
require "rails_helper"

describe VitaPartner do
  describe ".allows_greeters" do
    let!(:coalition) { create :coalition }
    let!(:organization) { create :organization, coalition: coalition, allows_greeters: true }
    let!(:site) { create :site, parent_organization: organization }
    let!(:other_organization) { create :organization, allows_greeters: true }
    let!(:other_site) { create :site, parent_organization: other_organization }
    let!(:not_accessible_org) { create :organization, name: "Not accessible", allows_greeters: false }
    let!(:not_accessible_site) { create :site, parent_organization: not_accessible_org }
    let(:user) { create :user, role: create(:greeter_role) }

    it "returns all the organizations (and their sites) where allows greeters is true" do
      vita_partners = VitaPartner.allows_greeters
      national_org = Organization.where(name: "GYR National Organization").first
      expect(vita_partners).to match_array([national_org, organization, other_organization, site, other_site])
      expect(vita_partners).not_to include(not_accessible_org)
      expect(vita_partners).not_to include(not_accessible_site)
    end
  end

  describe ".client_support_org" do
    context "national org already exists" do
      # The national org is created in rails_helper

      it "returns the org" do
        expect(described_class.client_support_org.name).to eq("GYR National Organization")
      end
    end

    context "national org does not exist" do
      before { VitaPartner.client_support_org.delete }

      it "raises an error" do
        expect {
          described_class.client_support_org
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
