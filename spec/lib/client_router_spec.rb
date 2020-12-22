require "rails_helper"

RSpec.describe ClientRouter do
  describe ".route" do
    context "with more than one organization" do
      let!(:small_organization) { create(:organization) }
      let!(:big_organization) { create(:organization) }
      let(:intake) { create :intake }

      before do
        create_list(:organization_lead_role, 3, organization: big_organization)
        create(:organization_lead_role, organization: small_organization)
      end

      it "assigns to the one with the most org leads" do
        described_class.route(intake.client)

        expect(intake.reload.client.vita_partner).to eq(big_organization)
        expect(intake.reload.vita_partner).to eq(big_organization)
      end
    end

    context "when client already has a .vita_partner" do
      let(:old_organization) { create(:organization) }
      let!(:big_organization) { create(:organization) }
      let(:intake) { create(:intake, vita_partner: old_organization) }

      before do
        intake.client.update(vita_partner: old_organization)
        create(:organization_lead_role, organization: big_organization)
      end

      it "re-assigns" do
        described_class.route(intake.client)

        expect(intake.reload.client.vita_partner).to eq(big_organization)
        expect(intake.reload.vita_partner).to eq(big_organization)
      end
    end
  end
end
