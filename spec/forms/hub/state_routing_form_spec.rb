require "rails_helper"

RSpec.describe Hub::StateRoutingForm do
  let!(:vps_1) { create :state_routing_target, routing_fraction: 0.0, state: "FL" }
  let!(:vps_2) { create :state_routing_target, routing_fraction: 0.1, state: "FL" }
  describe "#initialize" do
    it "accepts a set of state_routing_attributes and assigns to vita partner states" do
      params = {}
      form = described_class.new(params, state: "FL")
      expect(form.state_routing_targets).to match_array StateRoutingTarget.where(state: "FL")
    end
  end

  describe "#save" do
    context "when values add up to 100%" do
      context "updating existing vita partner state objects" do
        let(:params) {
          { state_routing_targets_attributes: {
              "0" => {
                  id: vps_1.id,
                  vita_partner_id: vps_1.vita_partner.id,
                  routing_percentage: 60
              },
              "1" => {
                  id: vps_2.id,
                  vita_partner_id: vps_2.vita_partner.id,
                  routing_percentage: 40
              }
          } }
        }
        it "saves the vita partner state" do
          form = Hub::StateRoutingForm.new(params, state: "FL")
          form.save

          expect(vps_1.reload.routing_fraction).to eq 0.6
          expect(vps_2.reload.routing_fraction).to eq 0.4
        end
      end

      context "creating vita partner state objects" do
        let(:vita_partner) { create :organization }
        let(:params) {
          { state_routing_targets_attributes: {
              "0" => {
                  id: vps_1.id,
                  vita_partner_id: vps_1.vita_partner.id,
                  routing_percentage: 60
              },
              "1" => {
                  vita_partner_id: vita_partner.id,
                  routing_percentage: 40
              }
          } }
        }

        it "creates a new vita partner state" do
          expect {
            form = Hub::StateRoutingForm.new(params, state: "FL")
            form.save
          }.to change(StateRoutingTarget, :count)

          expect(vps_1.reload.routing_fraction).to eq 0.6
          expect(StateRoutingTarget.last.routing_fraction).to eq 0.4
        end
      end
    end
  end

  describe "#valid?" do
    context "when proposed values add up to less than to 100%" do
      let(:params) {
        { state_routing_targets_attributes: {
            "0" => {
                id: vps_1.id,
                vita_partner_id: vps_1.vita_partner.id,
                routing_percentage: 20
            },
            "1" => {
                id: vps_2.id,
                vita_partner_id: vps_2.vita_partner.id,
                routing_percentage: 40
            }
        } }
      }
      it "adds an error" do
        form = Hub::StateRoutingForm.new(params, state: "FL")
        expect(form.valid?).to eq false
        expect(form.errors[:must_equal_100]).to be_present
      end
    end

    context "when proposed values add up to more than to 100%" do
      let(:params) {
        { state_routing_targets_attributes: {
            "0" => {
                id: vps_1.id,
                vita_partner_id: vps_1.vita_partner.id,
                routing_percentage: 90
            },
            "1" => {
                id: vps_2.id,
                vita_partner_id: vps_2.vita_partner.id,
                routing_percentage: 40
            }
        } }
      }
      it "adds an error" do
        form = Hub::StateRoutingForm.new(params, state: "FL")
        expect(form.valid?).to eq false
        expect(form.errors[:must_equal_100]).to be_present
      end
    end

    context "when there are duplicate entries for the same vita_partner_id" do
      let(:params) do
        { state_routing_targets_attributes: {
            "0" => {
                id: 1,
                routing_percentage: 40,
                vita_partner_id: 2
            },
            "1" => {
                id: 2,
                routing_percentage: 40,
                vita_partner_id: 1
            },
            "new" => {
                vita_partner_id: 1,
                routing_percentage: 20,
            }
        } }
      end
      it "is not valid and adds an error" do
        form = Hub::StateRoutingForm.new(params, state: "FL")
        form.valid?
        expect(form.valid?).to eq false
        expect(form.errors[:duplicate_vita_partner]).to be_present
      end
    end
  end
end