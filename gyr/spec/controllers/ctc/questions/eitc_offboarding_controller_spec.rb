require "rails_helper"

describe Ctc::Questions::EitcOffboardingController do
  let(:intake) { create :ctc_intake, claim_eitc: claim_eitc }
  let(:eitc_eligible) { true }
  let(:claim_eitc) { "yes" }
  let(:benefits_eligibility) { instance_double(Efile::BenefitsEligibility) }

  before do
    allow(Efile::BenefitsEligibility).to receive(:new).and_return benefits_eligibility
    allow(benefits_eligibility).to receive(:qualified_for_eitc_pre_w2s?).and_return eitc_eligible
    sign_in intake.client
  end

  describe ".show?" do
    context "with the feature flag enabled" do
      before do
        Flipper.enable :eitc
      end

      context "claiming eitc" do
        let(:claim_eitc) { "yes" }

        context "when they are not qualified for the eitc" do
          let(:eitc_eligible) { false }

          it "returns true" do
            expect(described_class.show?(intake, subject)).to eq true
          end
        end

        context "when they are qualified for the eitc" do
          let(:eitc_eligible) { true }

          it "returns false" do
            expect(described_class.show?(intake, subject)).to eq false
          end
        end
      end

      context "when they are not claiming" do
        let(:claim_eitc) { "no" }

        it "returns false" do
          expect(described_class.show?(intake, subject)).to eq false
        end
      end
    end

    context "with the feature flag disabled" do
      it "returns false" do
        expect(described_class.show?(intake, subject)).to eq false
      end
    end
  end
end
