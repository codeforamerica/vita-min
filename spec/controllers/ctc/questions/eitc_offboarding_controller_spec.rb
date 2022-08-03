require "rails_helper"

describe Ctc::Questions::EitcOffboardingController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe ".show?" do
    context "with the feature flag enabled" do
      before do
        Flipper.enable :eitc
      end

      context "when they are claiming and qualified for the eitc" do
        before do
          allow(intake).to receive(:qualified_for_eitc?).and_return true
          allow(intake).to receive(:claiming_eitc?).and_return true
        end

        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when they are not claiming and not qualified for the eitc" do
        before do
          allow(intake).to receive(:qualified_for_eitc?).and_return false
          allow(intake).to receive(:claiming_eitc?).and_return false
        end

        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when they are claiming but not qualified for the eitc" do
        before do
          allow(intake).to receive(:qualified_for_eitc?).and_return false
          allow(intake).to receive(:claiming_eitc?).and_return true
        end

        it "returns true" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "when they qualified for but not claiming the eitc" do
        before do
          allow(intake).to receive(:qualified_for_eitc?).and_return true
          allow(intake).to receive(:claiming_eitc?).and_return false
        end

        it "returns false" do
          expect(described_class.show?(intake)).to eq false
        end
      end
    end

    context "with the feature flag disabled" do
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
