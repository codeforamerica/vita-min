require "rails_helper"

describe Organization do

  describe "#organization_leads" do
    let(:organization) { create :organization }
    let(:site) { create :site, parent_organization: organization }
    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:team_member) { create :team_member_user, site: site }

    it "returns users who are organization leads for the provided vita_partner" do
      expect(organization.organization_leads).to eq [lead]
      expect(organization.organization_leads).not_to include outside_lead
      expect(organization.organization_leads).not_to include team_member
    end
  end

  describe "#site_coordinators" do
    let(:organization) { create :organization }
    let(:site1) { create :site, parent_organization: organization }
    let(:site2) { create :site, parent_organization: organization }

    let!(:lead) { create :organization_lead_user, organization: organization }
    let!(:outside_lead) { create :organization_lead_user }
    let!(:site1_coordinator) { create :site_coordinator_user, site: site1 }
    let!(:site2_coordinator) { create :site_coordinator_user, site: site2 }
    let!(:team_member) { create :team_member_user, site: site1 }

    it "includes site coordinators from all child sites" do
      expect(organization.site_coordinators).to match_array([site1_coordinator, site2_coordinator])
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

    it "includes site coordinators from all child sites" do
      expect(organization.team_members).to match_array([site1_team_member, site2_team_member])
    end
  end
  
  describe "#at_capacity?" do
    let(:out_of_range_statuses) { TaxReturnStatus::STATUSES.keys - TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY }
    let(:in_range_statuses) { TaxReturnStatus::STATUS_KEYS_INCLUDED_IN_CAPACITY }
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
  end

  describe "#child_sites" do
    let(:organization) { create :organization }
    before do
      create_list(:site, 3, parent_organization: organization)
    end

    it "includes the sites an org has" do
      expect(organization.child_sites.count).to eq(3)
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

    it "cannot have the same name as another organization in the same coalition" do
      coalition = create :coalition
      create(:organization, coalition: coalition, name: "Oregano Org")
      new_org = build(:organization, coalition: coalition, name: "Oregano Org")
      expect(new_org).not_to be_valid
    end
  end

  describe "#allows_greeters?" do
    let(:allows_greeters) { true }
    let(:org) { create :organization, allows_greeters: allows_greeters }

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
end
