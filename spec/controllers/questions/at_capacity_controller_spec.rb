require "rails_helper"

RSpec.describe Questions::AtCapacityController do
  render_views
  let(:vita_partner) { create :vita_partner }
  let(:intake) { create :intake, vita_partner: vita_partner }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe ".show?" do
    context "when vita partner is at capacity" do
      before do
        vita_partner.update(capacity_limit: 0)
      end

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when vita partner is not yet at capacity" do
      before do
        vita_partner.update(capacity_limit: 10000)
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end

    context "when the intake has no vita partner" do
      before do
        intake.vita_partner = nil
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    it "saves viewed_at_capacity" do
      get :edit

      expect(intake.viewed_at_capacity).to be_truthy
    end
  end

  describe "#update" do
    it "saves continued_at_capacity" do
      post :update

      expect(intake.continued_at_capacity).to be_truthy
    end
  end
end
