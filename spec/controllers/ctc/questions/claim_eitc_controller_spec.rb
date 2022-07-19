require "rails_helper"

describe Ctc::Questions::ClaimEitcController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
  end

  describe ".show?" do
    context "with the env variable enabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:eitc).and_return true
      end

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "with the env variable disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:eitc).and_return false
      end

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end
  end

    describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end
  end
end
