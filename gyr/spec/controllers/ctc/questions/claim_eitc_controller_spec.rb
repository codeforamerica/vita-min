require "rails_helper"

describe Ctc::Questions::ClaimEitcController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
  end

  describe ".show?" do
    context "when open_for_eitc_intake? is true" do
      before do
        allow(subject).to receive(:open_for_eitc_intake?).and_return true
      end

      context "when the client home is not in puerto rico" do
        let(:intake) { create :ctc_intake, home_location: :fifty_states }

        it "returns true" do
          expect(described_class.show?(intake, subject)).to eq true
        end
      end

      context "when client home is in puerto rico" do
        let(:intake) { create :ctc_intake, home_location: :puerto_rico }

        it "returns false" do
          expect(described_class.show?(intake, subject)).to eq false
        end
      end
    end

    context "when open_for_eitc_intake? is false" do
      before do
        allow(subject).to receive(:open_for_eitc_intake?).and_return false
      end

      it "returns false" do
        expect(described_class.show?(intake, subject)).to eq false
      end
    end
  end

  describe "#edit" do
    before do
      allow(subject).to receive(:track_first_visit)
    end

    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end

    it "tracks the first visit to this page" do
      get :edit, params: {}
      expect(subject).to have_received(:track_first_visit).with(:claim_eitc)
    end
  end
end
