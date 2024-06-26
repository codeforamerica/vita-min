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

  def routing_params(partner_routing_percentages)
    {
      state_routing_fraction_attributes: partner_routing_percentages.to_h do |partner, percentage|
        [partner.id,
         {
          state_routing_target_id: coalition_1_state_routing_target.id,
          routing_percentage: percentage
         }
        ]
      end
    }
  end

  describe "#save" do
    context "when no new routing fractions are added" do
      let(:params) { routing_params({organization_1 => 60, organization_2 => 40}) }

      it "updates the existing state routing fraction objects" do
        form = Hub::StateRoutingForm.new(params)
        form.save

        expect(organization_1_state_routing_fraction.reload.routing_fraction).to eq 0.6
        expect(organization_2_state_routing_fraction.reload.routing_fraction).to eq 0.4
      end

      context "when routing fractions don't cleanly convert from ints to floats and back" do
        let(:params) { routing_params({organization_1 => 29, organization_2 => 71}) }

        it "still retains the entered values" do
          form = Hub::StateRoutingForm.new(params)
          form.save

          expect(organization_1_state_routing_fraction.reload.routing_percentage).to eq 29
          expect(organization_2_state_routing_fraction.reload.routing_percentage).to eq 71
        end

      end
    end

    context "when new routing fractions are added" do
      let(:organization_3) { create :organization }
      let(:params) { routing_params({ organization_1 => 50,
                                      organization_2 => 0,
                                      organization_3 => 50}) }

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
    context "percentages must add up to 100" do
      context "when proposed values add up to less than to 100%" do
        let(:params) { routing_params({organization_1 => 40, organization_2 => 40}) }

        it "adds an error" do
          form = Hub::StateRoutingForm.new(params)
          expect(form.valid?).to eq false
          expect(form.errors[:must_equal_100]).to be_present
        end
      end

      context "when proposed values add up to more than to 100%" do
        let(:params) { routing_params({organization_1 => 60, organization_2 => 70}) }

        it "adds an error" do
          form = Hub::StateRoutingForm.new(params)
          expect(form.valid?).to eq false
          expect(form.errors[:must_equal_100]).to be_present
        end
      end

      context "when proposed values add up to exactly 100%" do
        let(:params) { routing_params({organization_1 => 60, organization_2 => 40}) }

        it "is valid" do
          form = Hub::StateRoutingForm.new(params)
          expect(form.valid?).to eq true
        end
      end
    end

    context "fractions must belong to an organization OR its sites" do
      let!(:site_1) { create :site, parent_organization: organization_1 }
      let!(:site_2) { create :site, parent_organization: organization_1 }

      context "when there are routing fractions for an organization and its child site(s)" do
        let(:params) { routing_params({ organization_1 => 30,
                                        site_1 => 30,
                                        organization_2 => 40}) }

        it "adds an error" do
          form = Hub::StateRoutingForm.new(params)
          expect(form.valid?).to eq false
          expect(form.errors[:delegated_routing]).to be_present
        end
      end

      context "when routing fractions are for only an organization's child sites" do
        let(:params) { routing_params({ site_1 => 30,
                                        site_2 => 30,
                                        organization_2 => 40}) }

        it "is valid" do
          form = Hub::StateRoutingForm.new(params)
          expect(form.valid?).to eq true
        end
      end
    end
  end
end