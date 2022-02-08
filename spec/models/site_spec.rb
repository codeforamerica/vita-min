# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  accepts_itin_applicants    :boolean          default(FALSE)
#  allows_greeters            :boolean
#  archived                   :boolean          default(FALSE)
#  capacity_limit             :integer
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
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

describe Site do
  describe "#site_coordinators" do
    let(:organization) { create :organization }
    let(:site1) { create :site, parent_organization: organization }
    let(:site2) { create :site, parent_organization: organization }

    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:site1_coordinator) { create :site_coordinator_user, site: site1 }
    let!(:site2_coordinator) { create :site_coordinator_user, site: site2 }
    let!(:team_member) { create :team_member_user, site: site1 }

    it "only includes site coordinators from that site" do
      expect(site1.site_coordinators).to eq [site1_coordinator]
    end
  end

  describe "#team_members" do
    let(:organization) { create :organization }
    let(:site1) { create :site, parent_organization: organization }
    let(:site2) { create :site, parent_organization: organization }
    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:site1_team_member) { create :team_member_user, site: site1 }
    let!(:site2_team_member) { create :team_member_user, site: site2 }

    it "only includes team members from that site" do
      expect(site1.team_members).to eq [site1_team_member]
    end
  end
  
  describe "#at_capacity?" do
    let(:out_of_range_statuses) { TaxReturnStateMachine::EXCLUDED_FROM_CAPACITY }
    let(:in_range_statuses) { TaxReturnStateMachine.states - TaxReturnStateMachine::EXCLUDED_FROM_CAPACITY }
    let(:parent_organization) { create :organization, capacity_limit: 10 }
    let(:site) { create :site, parent_organization: parent_organization }

    context "when parent org is at capacity" do
      before do
        10.times do
          client = create :client, vita_partner: site, intake: create(:intake)
          create :tax_return, :intake_ready, client: client
        end
      end

      it "returns true" do
        expect(site.at_capacity?).to eq true
      end
    end

    context "when parent org is not at capacity" do
      before do
        2.times do
          client = create :client, vita_partner: site
          create :tax_return, :intake_ready, client: client
        end
      end

      it "returns false" do
        expect(site.at_capacity?).to eq false
      end
    end
  end

  describe "#allows_greeters?" do
    let(:allows_greeters) { true }
    let(:org) { create :organization, allows_greeters: allows_greeters }

    context "vita partner is an org" do
      context "allow_greeter is true" do
        it "returns true" do
          expect(org.allows_greeters?).to be true
        end
      end

      context "allow_greeter is false" do
        let(:allows_greeters) { false }
        it "returns false" do
          expect(org.allows_greeters?).to be false
        end
      end
    end

    context "vita partner is a site" do
      let(:site) { create :site, parent_organization: org }

      context "allow_greeter for the parent organization is true" do
        it "returns true" do
          expect(site.allows_greeters?).to be true
        end
      end

      context "allow_greeter for the parent organization is false" do
        let(:allows_greeters) { false }
        it "returns false" do
          expect(site.allows_greeters?).to be false
        end
      end
    end
  end

  describe "validations" do
    let(:organization) { create :organization }
    let!(:valid_params) {
      {
        name: "Salty Site",
        parent_organization_id: organization.id
      }
    }

    it "can be valid" do
      expect(described_class.new(valid_params)).to be_valid
    end


    context "another site with the same name exists" do
      let!(:site) { create(:site, parent_organization: organization, name: "Salty Site") }

      it "is not valid" do
        expect(described_class.new(valid_params)).not_to be_valid
      end
    end

    context "with a coalition_id" do
      let!(:invalid_params) {
        {
          name: "Salty Site",
          parent_organization_id: organization.id,
          coalition_id: create(:coalition).id
        }
      }
      it "is not valid" do
        expect(described_class.new(invalid_params)).not_to be_valid
      end
    end

    context "with a capacity" do
      let!(:invalid_params) {
        {
          name: "Salty Site",
          parent_organization_id: organization.id,
          capacity_limit: 100
        }
      }
      it "is not valid" do
        expect(described_class.new(invalid_params)).not_to be_valid
      end
    end

    context "with an allows greeters value" do
      let!(:invalid_params) {
        {
          name: "Salty Site",
          parent_organization_id: organization.id,
          allows_greeters: false
        }
      }
      it "is not valid" do
        expect(described_class.new(invalid_params)).not_to be_valid
      end
    end
  end
end
