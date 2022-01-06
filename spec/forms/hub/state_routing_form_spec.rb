require "rails_helper"

RSpec.describe Hub::StateRoutingForm do
  let!(:coalition_1) { create :coalition }
  let!(:coalition_1_state_routing_target) { create :state_routing_target, state_abbreviation: "CA", target: coalition_1 }
  let(:organization_1) { create :organization, coalition: coalition_1 }
  let!(:organization_1_state_routing_fraction) {
    create(
      :state_routing_fraction,
      state_routing_target: coalition_1_state_routing_target,
      routing_fraction: 0.4,
      organization: organization_1
    )
  }
  let(:organization_2) { create :organization, coalition: coalition_1 }
  let!(:organization_2_state_routing_fraction) {
    create(
      :state_routing_fraction,
      state_routing_target: coalition_1_state_routing_target,
      routing_fraction: 0.6,
      organization: organization_2
    )
  }

  describe "#save" do
    context "when no new routing fractions are added" do
      let(:params) do
        {
          state_routing_fraction_attributes: {
            organization_1.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 60
            },
            organization_2.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 40
            }
          }
        }
      end

      it "updates the existing state routing fraction objects" do
        form = Hub::StateRoutingForm.new(params)
        form.save

        expect(organization_1_state_routing_fraction.reload.routing_fraction).to eq 0.6
        expect(organization_2_state_routing_fraction.reload.routing_fraction).to eq 0.4
      end
    end

    context "when new routing fractions are added" do
      let(:organization_3) { create :organization }
      let(:params) do
        {
          state_routing_fraction_attributes: {
            organization_1.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 50
            },
            organization_2.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 0
            },
            organization_3.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 50
            }
          }
        }
      end

      it "creates new state routing fraction objects" do
        expect {
          form = Hub::StateRoutingForm.new(params)
          form.save
        }.to change(StateRoutingFraction, :count).from(2).to(3)

        expect(organization_1_state_routing_fraction.reload.routing_fraction).to eq 0.5
        expect(organization_2_state_routing_fraction.reload.routing_fraction).to eq 0.0
        new_organization_3_fraction = StateRoutingFraction.where(vita_partner_id: organization_3, state_routing_target_id: coalition_1_state_routing_target.id).first
        expect(new_organization_3_fraction.routing_fraction).to eq 0.5
      end
    end
  end

  describe "#valid?" do
    context "when proposed values add up to less than to 100%" do
      let(:params) do
        {
          state_routing_fraction_attributes: {
            organization_1.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 40
            },
            organization_2.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 40
            }
          }
        }
      end

      it "adds an error" do
        form = Hub::StateRoutingForm.new(params)
        expect(form.valid?).to eq false
        expect(form.errors[:must_equal_100]).to be_present
      end
    end

    context "when proposed values add up to more than to 100%" do
      let(:params) do
        {
          state_routing_fraction_attributes: {
            organization_1.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 60
            },
            organization_2.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 70
            }
          }
        }
        end

      it "adds an error" do
        form = Hub::StateRoutingForm.new(params)
        expect(form.valid?).to eq false
        expect(form.errors[:must_equal_100]).to be_present
      end
    end

    context "when there are duplicate entries for the same vita_partner_id" do
      let(:params) do
        {
          state_routing_fraction_attributes: {
            organization_1.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 30
            },
            organization_2.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 60
            },
            organization_2.id => {
              state_routing_target_id: coalition_1_state_routing_target.id,
              routing_percentage: 10
            }
          }
        }
      end

      it "adds an error" do
        # CT: ok so here's what happened: this validation was checking for the vita_partner_id value, which we removed because it was redundant with the key
        # the thing is you actually can't make a hash with two of the same key, duh
        # so it doesn't register this as having a duplicate
        # i think this validation actually belongs in the form where you add a new routing target
        form = Hub::StateRoutingForm.new(params)
        form.valid?
        expect(form.valid?).to eq false
        expect(form.errors[:duplicate_vita_partner]).to be_present
      end
    end
  end
end