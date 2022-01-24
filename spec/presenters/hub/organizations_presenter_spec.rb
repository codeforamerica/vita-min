require "rails_helper"

describe Hub::OrganizationsPresenter do
  subject { described_class.new(ability) }

  let!(:organization) { create :organization, capacity_limit: 250 }
  let!(:coalition) { create :coalition }
  let!(:high_capacity_unrouted_organization) { create :organization, coalition: coalition, capacity_limit: 500 }
  let!(:unrouted_organization) { create :organization }
  let!(:unrouted_organization_with_coalition) { create :organization, coalition: create(:coalition) }

  before do
    create :state_routing_target, target: organization, state_abbreviation: "CA"
    create :state_routing_target, target: coalition, state_abbreviation: "CA"
    create :state_routing_target, target: organization, state_abbreviation: "TX"
    create :client, :with_return, vita_partner: organization, status: "review_ready_for_qr"
  end

  context "with an admin user with admin abilities" do
    let(:user) { create :admin_user }
    let(:ability) { Ability.new(user) }

    describe "#accessible_entities_for" do
      it "returns a collection of coalitions and organizations where there are state routing rules" do
        expect(subject.accessible_entities_for("CA")).to include coalition
        expect(subject.accessible_entities_for("CA")).to include organization
        expect(subject.accessible_entities_for("TX")).to eq [organization]
      end
    end

    describe "#coalition_capacity" do
      it "returns information about the coalition's capacity" do
        capacity = subject.coalition_capacity(coalition)
        expect(capacity.current_count).to eq 0
        expect(capacity.total_capacity).to eq 500
      end
    end

    describe "#state_capacity" do
      it "returns capacity for organization based on state BUT can make no designation between capacity per state" do
        capacity = subject.state_capacity("TX")
        expect(capacity.current_count).to eq 1
        expect(capacity.total_capacity).to eq 250

        capacity = subject.state_capacity("CA")
        expect(capacity.current_count).to eq 1
        expect(capacity.total_capacity).to eq 750 # organization + coalition capacity
      end
    end

    describe "#organization_capacity" do
      it "returns the capacity figures" do
        capacity = subject.organization_capacity(organization)
        expect(capacity.total_capacity).to eq 250
        expect(capacity.current_count).to eq 1
      end
    end

    describe "#unrouted_organizations" do
      it "returns a collection of the organizations that have no state routing rules" do
        ctc_org = Organization.find_by(name: "GetCTC.org")
        national_org = VitaPartner.find_by(name: "GYR National Organization")
        expect(subject.unrouted_organizations).to match_array([
          unrouted_organization,
          unrouted_organization_with_coalition,
          high_capacity_unrouted_organization,
          national_org,
          ctc_org
        ])
      end
    end
  end

  context "with a user who can only access the organization" do
    let(:user) { create :organization_lead_user, organization: organization }
    let(:ability) { Ability.new(user) }

    describe "#accessible_entities_for" do
      it "returns a collection of the organizations by state routing rules" do
        expect(subject.accessible_entities_for("CA")).to eq [organization]
        expect(subject.accessible_entities_for("TX")).to eq [organization]
      end
    end

    describe "#coalition_capacity" do
      it "returns nil because the user has no coalition access" do
        expect(subject.coalition_capacity(coalition)).to eq nil
      end
    end

    describe "#state_capacity" do
      it "returns capacity for organization based on state BUT can make no designation between capacity per state" do
        capacity = subject.state_capacity("TX")
        expect(capacity.current_count).to eq 1
        expect(capacity.total_capacity).to eq 250

        capacity = subject.state_capacity("CA")
        expect(capacity.current_count).to eq 1
        expect(capacity.total_capacity).to eq 250
      end
    end

    describe "#organization_capacity" do
      context "when there is access to the organization" do
        it "returns the capacity figures" do
          capacity = subject.organization_capacity(organization)
          expect(capacity.total_capacity).to eq 250
          expect(capacity.current_count).to eq 1
        end
      end

      context "when the user cannot access the organization" do
        it "returns nil" do
          expect(subject.organization_capacity(coalition.organizations.first)).to eq nil
        end
      end
    end

    describe "#unrouted_organizations" do
      context "with a user with access to one unrouted organization" do
        let(:user) { create(:user, role: create(:organization_lead_role, organization: unrouted_organization)) }

        it "returns just the one organization even though other unrouted orgs exist" do
          expect(subject.unrouted_organizations).to match_array([unrouted_organization])
        end
      end
    end
  end
end