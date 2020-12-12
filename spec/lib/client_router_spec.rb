require "rails_helper"

RSpec.describe ClientRouter do
  describe ".route" do
    context "with more than one vita partner" do
      let!(:big_vita_partner) { create(:vita_partner, users: create_list(:user, 3)) }
      let!(:small_vita_partner) { create(:vita_partner, users: create_list(:user, 1)) }
      let(:intake) { create :intake }

      it "assigns to the one with the most users" do
        described_class.route(intake.client)

        expect(intake.reload.client.vita_partner).to eq(big_vita_partner)
        expect(intake.reload.vita_partner).to eq(big_vita_partner)
      end
    end

    context "when client already has a vita_partner" do
      let(:old_vita_partner) { create(:vita_partner) }
      let!(:big_vita_partner) { create(:vita_partner, users: create_list(:user, 3)) }
      let(:intake) { create(:intake, vita_partner: old_vita_partner) }

      before do
        intake.client.update(vita_partner: old_vita_partner)
      end

      it "re-assigns" do
        described_class.route(intake.client)

        expect(intake.reload.client.vita_partner).to eq(big_vita_partner)
        expect(intake.reload.vita_partner).to eq(big_vita_partner)
      end
    end
  end
end
