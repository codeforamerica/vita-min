# == Schema Information
#
# Table name: vita_partners
#
#  id                      :bigint           not null, primary key
#  accepts_overflow        :boolean          default(FALSE)
#  display_name            :string
#  logo_path               :string
#  name                    :string           not null
#  source_parameter        :string
#  weekly_capacity_limit   :integer
#  zendesk_instance_domain :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  zendesk_group_id        :string           not null
#
require "rails_helper"

describe VitaPartner do
  describe "#at_capacity?" do
    let(:vita_partner) { create(:vita_partner, weekly_capacity_limit: 10) }

    before do
      recent_intake_count.times do |n|
        create(
          :intake,
          primary_consented_to_service_at: 1.minute.since((n % 7).days.ago),
          intake_ticket_id: 1000 + n,
          vita_partner: vita_partner
        )
      end
    end

    context "recently consented intakes with Zendesk ticket count is at capacity limit" do
      let(:recent_intake_count) { vita_partner.weekly_capacity_limit }
      it "returns true" do
        expect(vita_partner).to be_at_capacity
      end
    end

    context "recently consented intakes with Zendesk ticket count is above capacity limit" do
      let(:recent_intake_count) { vita_partner.weekly_capacity_limit + 1}
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
end
