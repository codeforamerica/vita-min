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
#  processes_ctc              :boolean          default(FALSE)
#  timezone                   :string           default("America/New_York")
#  type                       :string
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

  describe ".organization_leads" do
    let(:organization) { create :organization }
    let(:site) { create :site, parent_organization: organization }
    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:team_member) { create :team_member_user, site: site }

    context "as a vita_partner that is an organization" do
      it "returns users who are organization leads for the provided vita_partner" do
        expect(organization.organization_leads).to eq [lead]
        expect(organization.organization_leads).not_to include outside_lead
        expect(organization.organization_leads).not_to include team_member
      end
    end

    context "as a vita_partner that is a site" do
      it "returns an empty collection" do
        expect(site.organization_leads).to eq []
      end
    end
  end

  describe ".site_coordinators" do
    let(:organization) { create :organization }
    let(:site1) { create :site, parent_organization: organization }
    let(:site2) { create :site, parent_organization: organization }

    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:site1_coordinator) { create :site_coordinator_user, site: site1 }
    let!(:site2_coordinator) { create :site_coordinator_user, site: site2 }
    let!(:team_member) { create :team_member_user, site: site1 }

    context "when the vita partner is a site" do
      it "only includes site coordinators from that site" do
        expect(site1.site_coordinators).to eq [site1_coordinator]
      end
    end

    context "when the vita partner is an organization with child sites" do
      it "includes site coordinators from all child sites" do
        expect(organization.site_coordinators).to match_array([site1_coordinator, site2_coordinator])
      end
    end
  end

  describe ".team_members" do
    let(:organization) { create :organization }
    let(:site1) { create :site, parent_organization: organization }
    let(:site2) { create :site, parent_organization: organization }
    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:site1_team_member) { create :team_member_user, site: site1 }
    let!(:site2_team_member) { create :team_member_user, site: site2 }

    context "when the vita partner is a site" do
      it "only includes site coordinators from that site" do
        expect(site1.team_members).to eq [site1_team_member]
      end
    end

    context "when the vita partner is an organization with child sites" do
      it "includes site coordinators from all child sites" do
        expect(organization.team_members).to match_array([site1_team_member, site2_team_member])
      end
    end
  end

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
      national_org = VitaPartner.where(name: "GYR National Organization").first
      expect(vita_partners).to match_array([national_org, organization, other_organization, site, other_site])
      expect(vita_partners).not_to include(not_accessible_org)
      expect(vita_partners).not_to include(not_accessible_site)
    end
  end
  
  describe "#at_capacity?" do
    let(:out_of_range_statuses) { TaxReturnStatus::STATUSES.keys - TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY }
    let(:in_range_statuses) { TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY }

    context "an organization" do
      let(:organization) { create :organization, capacity_limit: 10 }

      context "at capacity" do
        before do
          organization.capacity_limit.times do
            client = create :client, vita_partner: organization
            create :tax_return, status: "intake_ready", client: client
          end
        end

        it "returns true" do
          expect(organization).to be_at_capacity
        end
      end

      context "over capacity" do
        context "clients assigned to organization exceed capacity limit" do
          before do
            (organization.capacity_limit + 1).times do
              client = create :client, vita_partner: organization
              create :tax_return, status: in_range_statuses.sample, client: client
            end
          end

          it "returns true" do
            expect(organization).to be_at_capacity
          end
        end

        context "sum of clients assigned to sites within organization exceed capacity limit" do
          let(:site_1) { create :site, parent_organization: organization }
          let(:site_2) { create :site, parent_organization: organization }

          before do
            (organization.capacity_limit + 1).times do
              client = create :client, vita_partner: [site_1, site_2, organization].sample
              create :tax_return, status: in_range_statuses.sample, client: client
            end
          end

          it "returns true" do
            expect(organization).to be_at_capacity
          end
        end
      end

      context "under capacity" do
        context "total number of clients is less than capacity limit" do
          before do
            (organization.capacity_limit - 1).times do
              client = create :client, vita_partner: organization
              create :tax_return, client: client
            end
          end

          it "returns false" do
            expect(organization).not_to be_at_capacity
          end
        end

        context "number of clients in status range is less than capacity limit" do
          before do
            (organization.capacity_limit / 2).times do
              client = create :client, vita_partner: organization
              create :tax_return, status: out_of_range_statuses.sample, client: client
            end

            (organization.capacity_limit / 2).times do
              client = create :client, vita_partner: organization
              create :tax_return, status: in_range_statuses.sample, client: client
            end
          end

          it "returns false" do
            expect(organization).not_to be_at_capacity
          end
        end
      end
    end

    context "with no capacity set" do
      let(:organization) { create :organization }
      before do
        20.times do
          client = create :client, vita_partner: organization
          create :tax_return, status: "intake_ready", client: client
        end
      end

      it "always returns false" do
        expect(organization).not_to be_at_capacity
      end
    end

    context "a site" do
      let(:parent_organization) { create :organization, capacity_limit: 10 }
      let(:site) { create :site, parent_organization: parent_organization }

      context "when parent org is at capacity" do
        before do
          10.times do
            client = create :client, vita_partner: site
            create :tax_return, status: "intake_ready", client: client
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
            create :tax_return, status: "intake_ready", client: client
          end
        end

        it "returns false" do
          expect(site.at_capacity?).to eq false
        end
      end
    end
  end

  context "site-specific properties" do
    context "with a parent_organization_id" do
      let(:organization) { create(:vita_partner) }
      let(:site) { create(:vita_partner, parent_organization: organization) }

      it "is a site" do
        expect(site.site?).to eq(true)
        expect(site.organization?).to eq(false)
        expect(VitaPartner.sites).to include site
      end

      it "cannot be added to a coalition" do
        coalition = create(:coalition)
        site.coalition = coalition
        expect(site).not_to be_valid
      end

      it "cannot have the same name as another site in the same organization" do
        create(:site, parent_organization: organization, name: "Salty Site")
        new_site = build(:site, parent_organization: organization, name: "Salty Site")
        expect(new_site).not_to be_valid
      end
    end

    it "cannot be assigned a capacity" do
      site = VitaPartner.new(parent_organization: create(:organization), capacity_limit: 1)
      expect(site.valid?).to eq false
    end

    it "allows_greeters cannot be assigned a value" do
      site = VitaPartner.new(parent_organization: create(:organization), allows_greeters: false)
      expect(site.valid?).to eq false
    end
  end

  context "organization-specific properties" do
    context "without a parent_organization_id" do
      let(:organization) { create(:vita_partner, parent_organization: nil) }

      it "is an organization" do
        expect(organization.organization?).to eq(true)
        expect(organization.site?).to eq(false)
        expect(VitaPartner.organizations).to include organization
      end

      it "cannot have the same name as another organization in the same coalition" do
        coalition = create :coalition
        create(:organization, coalition: coalition, name: "Oregano Org")
        new_org = build(:organization, coalition: coalition, name: "Oregano Org")
        expect(new_org).not_to be_valid
      end

      describe "#child_sites" do
        before do
          create_list(:site, 3, parent_organization: organization)
        end

        it "includes the sites an org has" do
          expect(organization.child_sites.count).to eq(3)
        end
      end
    end
  end

  context "sub-organizations" do
    let(:vita_partner) { create(:vita_partner) }

    it "permits one level of depth" do
      child = VitaPartner.new(
        name: "Child", parent_organization: vita_partner
      )
      expect(child).to be_valid
    end

    it "does not permit two levels of depth" do
      child = create(:vita_partner, parent_organization: vita_partner)
      grandchild = VitaPartner.new(
        name: "Grand Child", parent_organization: child
      )
      expect(grandchild).not_to be_valid
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

  describe "validations" do
    let!(:valid_params) {
      {
        name: "Coala Org"
      }
    }
    it "can be valid" do
      expect(described_class.new(valid_params)).to be_valid
    end

    it "validates that capacity limit is a number" do
      valid_params[:capacity_limit] = "not number"

      expect(described_class.new(valid_params)).not_to be_valid
    end

    it "validates that capacity limit is a positive number" do
      valid_params[:capacity_limit] = -1

      expect(described_class.new(valid_params)).not_to be_valid
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
end
