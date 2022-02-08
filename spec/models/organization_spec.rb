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
    let(:out_of_range_statuses) { TaxReturnStateMachine::EXCLUDED_FROM_CAPACITY }
    let(:in_range_statuses) { TaxReturnStateMachine.states - TaxReturnStateMachine::EXCLUDED_FROM_CAPACITY }
    let(:organization) { create :organization, capacity_limit: 10 }

    context "at capacity" do
      before do
        organization.capacity_limit.times do
          client = create :client, vita_partner: organization, intake: create(:intake)
          create :tax_return, state: "intake_ready", client: client
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
            client = create :client, vita_partner: organization, intake: create(:intake)
            create :tax_return, :prep_ready_for_prep, client: client
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
            client = create :client, vita_partner: [site_1, site_2, organization].sample, intake: create(:intake)
            create :tax_return, state: :review_in_review, client: client
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
            create :tax_return, state: out_of_range_statuses.sample, client: client
          end

          (organization.capacity_limit / 2).times do
            client = create :client, vita_partner: organization
            create :tax_return, state: in_range_statuses.sample, client: client
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
          create :tax_return, state: "intake_ready", client: client
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
    let(:capacity_limit) { nil }
    let(:state_routing_targets) { [] }
    let(:coalition) { nil }
    let(:params) {
      {
        coalition: coalition,
        name: "Coala Org",
        state_routing_targets: state_routing_targets,
        capacity_limit: capacity_limit,
      }
    }
    let(:subject) { described_class.new(params) }

    context "with valid params" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when capacity limit is not a number" do
      let(:capacity_limit) { "not number" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:capacity_limit)
      end
    end

    context "when capacity limit is negative" do
      let(:capacity_limit) { -1 }
      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors).to include(:capacity_limit)
      end
    end

    context "when it shares the name as another organization in the same coalition" do
      let(:coalition) { create(:coalition) }

      before do
        create(:organization, coalition: coalition, name: "Oregano Org")
      end

      it "is not valid" do
        new_org = build(:organization, coalition: coalition, name: "Oregano Org")
        expect(new_org).not_to be_valid
        expect(new_org.errors).to include(:name)
      end
    end

    context "when it is part of a coalition" do
      let(:coalition) { build(:coalition) }

      it "can be valid" do
        expect(subject).to be_valid
      end

      context "when it also has state routing targets" do
        let(:state_routing_targets) { [build(:state_routing_target, state_abbreviation: "CA")] }

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors).to include(:coalition)
        end
      end
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
