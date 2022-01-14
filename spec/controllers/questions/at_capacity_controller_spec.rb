require "rails_helper"

RSpec.describe Questions::AtCapacityController do
  render_views
  let(:vita_partner) { create :organization }
  let(:intake) { create :intake, vita_partner: vita_partner }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe ".show?" do
    context "when the clients routing method is set to at_capacity" do
      before do
        intake.client.update(routing_method: "at_capacity")
      end

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end
  end

  describe "#edit" do
    it "saves viewed_at_capacity" do
      get :edit

      expect(intake.viewed_at_capacity).to be_truthy
    end
  end
end
