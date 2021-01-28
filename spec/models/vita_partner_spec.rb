# == Schema Information
#
# Table name: vita_partners
#
#  id                         :bigint           not null, primary key
#  archived                   :boolean          default(FALSE)
#  logo_path                  :string
#  name                       :string           not null
#  national_overflow_location :boolean          default(FALSE)
#  weekly_capacity_limit      :integer
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
  context "capacity" do
    let(:routing_criteria) { "source_parameter" }
    let(:recent_intake_count) { 0 }

    before do
      create_list(
        :intake,
        recent_intake_count,
        vita_partner: vita_partner,
        primary_consented_to_service_at: rand(1...6).days.ago,
        intake_ticket_id: 12345,
        routing_criteria: routing_criteria,
      )
    end

    describe "#at_capacity?" do
      let(:vita_partner) { create(:vita_partner, weekly_capacity_limit: 10) }

      context "recently consented intakes with Zendesk ticket count is at capacity limit" do
        let(:recent_intake_count) { vita_partner.weekly_capacity_limit }

        it "returns true" do
          expect(vita_partner).to be_at_capacity
        end
      end

      context "recently consented intakes with Zendesk ticket count is above capacity limit" do
        let(:recent_intake_count) { vita_partner.weekly_capacity_limit + 1 }

        it "returns true" do
          expect(vita_partner).to be_at_capacity
        end
      end

      context "recently consented intakes with Zendesk ticket count is less than capacity limit" do
        let(:recent_intake_count) do
          vita_partner.weekly_capacity_limit - 1
        end

        it "returns false" do
          expect(vita_partner).not_to be_at_capacity
        end

        context "when there are partner intakes consented more than a week ago" do
          before do
            create(
              :intake,
              primary_consented_to_service_at: 7.days.ago,
              vita_partner: vita_partner
            )
          end

          it "returns false" do
            expect(vita_partner).not_to be_at_capacity
          end
        end

        context "when there are recently consented partner intakes without tickets" do
          before do
            create(
              :intake,
              primary_consented_to_service_at: 1.days.ago,
              vita_partner: vita_partner
            )
          end

          it "returns false" do
            expect(vita_partner).not_to be_at_capacity
          end
        end

        context "when there are partner intakes that have not been consented to" do
          before do
            create(
              :intake,
              primary_consented_to_service_at: nil,
              intake_ticket_id: 123,
              vita_partner: vita_partner
            )
          end

          it "returns false" do
            expect(vita_partner).not_to be_at_capacity
          end
        end
      end
    end

    describe "#has_capacity_for?" do
      let(:intake) { create :intake, vita_partner: vita_partner, routing_criteria: routing_criteria }

      context "for the special situation of Urban Upbound" do
        let(:vita_partner) do
          create(
            :vita_partner,
            name: "Urban Upbound (NY)",
          )
        end

        context "with an intake referred by source parameter" do
          let(:routing_criteria) { "source_parameter" }

          it "always has capacity" do
            expect(vita_partner.has_capacity_for?(intake)).to eq true
          end
        end

        context "with an intake in UUNY's list of states" do
          let(:routing_criteria) { "state" }

          it "always has capacity" do
            expect(vita_partner.has_capacity_for?(intake)).to eq true
          end
        end

        context "with an overflow intake" do
          let(:routing_criteria) { "overflow" }

          context "under 50 overflow intakes this week" do
            let(:recent_intake_count) { 5 }

            it "has capacity for the intake" do
              expect(vita_partner.has_capacity_for?(intake)).to eq true
            end
          end

          context "more than 50 overflow intakes this week" do
            let(:recent_intake_count) { 51 }

            it "does not have capacity for this intake" do
              expect(vita_partner.has_capacity_for?(intake)).to eq false
            end
          end
        end
      end

      context "in all other cases" do
        let(:vita_partner) { create :vita_partner }

        before do
          allow(vita_partner).to receive(:at_capacity?).and_return(false)
        end

        it "just checks for the partner's default capacity" do
          expect(vita_partner.has_capacity_for?(intake)).to eq true
          expect(vita_partner).to have_received(:at_capacity?)
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
        expect(VitaPartner.sites).to eq [site]
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
end
