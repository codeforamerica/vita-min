require "rails_helper"

describe Ctc::Questions::ClaimEitcController do
  let(:intake) { create :ctc_intake }

  before do
    session[:intake_id] = intake.id
  end

  describe ".show?" do
    context "with the env variable enabled" do
      before do
        Flipper.enable :eitc
      end

      it "returns true" do
        expect(described_class.show?(intake, subject)).to eq true
      end

      context "when client home is in puerto rico" do
        let(:intake) { create :ctc_intake, home_location: :puerto_rico }

        it "returns false" do
          expect(described_class.show?(intake, subject)).to eq false
        end
      end
    end

    context "with the env variable disabled" do
      it "returns false" do
        expect(described_class.show?(intake, subject)).to eq false
      end
    end
  end

  describe "#edit" do
    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit
    end

    before do
      allow(subject).to receive(:track_first_visit)
      sign_in intake.client
    end

    it "tracks the first visit to this page" do
      get :edit, params: {}
      expect(subject).to have_received(:track_first_visit).with(:claim_eitc)
    end
  end
end
