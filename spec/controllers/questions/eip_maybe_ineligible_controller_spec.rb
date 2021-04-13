require "rails_helper"

RSpec.describe Questions::EipMaybeIneligibleController do
  describe ".show?" do
    context "when intake meets triage_eligibility requirements" do
      let(:intake) { create :intake, claimed_by_another: "no", already_applied_for_stimulus: "no", no_ssn: "no" }

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when intake does not meet triage_eligibility requirements" do
      let(:intake) { create :intake, claimed_by_another: "no", already_applied_for_stimulus: "yes", no_ssn: "no" }

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end
end