# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  accepts_overflow        :boolean          default(FALSE)
#  archived                :boolean          default(FALSE)
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  weekly_capacity_limit   :integer
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  parent_organization_id  :bigint
#  zendesk_group_id        :string           not null
#
# Indexes
#
#  index_vita_partners_on_parent_organization_id  (parent_organization_id)
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
            zendesk_group_id: "360010243314",
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

  context "select options" do
    let(:parent_org1) { create(:vita_partner, name: "First Parent Org") }
    let(:parent_org2) { create(:vita_partner, name: "Second Parent Org") }
    let(:parent_org3) { create(:vita_partner, name: "No Child Org") }
    let(:sub_org1) { create(:vita_partner, parent_organization_id: parent_org1.id, name: "The First Child Org") }
    let(:sub_org2) { create(:vita_partner, parent_organization_id: parent_org1.id, name: "The Second Child Org") }
    let(:sub_org3) { create(:vita_partner, parent_organization_id: parent_org2.id, name: "The Third Child Org") }

    describe "#select_optgroup_input_options" do
      it "returns array grouped by parent org" do
        expected =
          [
            ["First Parent Org", [["First Parent Org", parent_org1.id], ["The First Child Org", sub_org1.id], ["The Second Child Org",  sub_org2.id]]],
            ["Second Parent Org", [["Second Parent Org", parent_org2.id], ["The Third Child Org", sub_org3.id]]],
            ["No Child Org", [["No Child Org", parent_org3.id]]]
          ]

        expect(VitaPartner.grouped_org_options).to eq(expected)
      end
    end
  end

  context "sub-organizations" do
    let(:vita_partner) { create(:vita_partner) }

    it "permits one level of depth" do
      child = VitaPartner.new(
        name: "Child", parent_organization: vita_partner, zendesk_group_id: "child_group_id", zendesk_instance_domain: "eitc"
      )
      expect(child).to be_valid
    end

    it "does not permit two levels of depth" do
      child = create(:vita_partner, parent_organization: vita_partner)
      grandchild = VitaPartner.new(
        name: "Grand Child", parent_organization: child, zendesk_group_id: "grandchild_group_id", zendesk_instance_domain: "eitc"
      )
      expect(grandchild).not_to be_valid
    end
  end
end
