require 'rails_helper'

RSpec.describe StateFile::Questions::EligibilityOffboardingController do
  describe ".show?" do
    context "when the intake has a disqualifying answer" do
      it "returns true" do
        intake = double("intake", has_disqualifying_eligibility_answer?: true)
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the intake does not have a disqualifying answer" do
      it "returns false" do
        intake = double("intake", has_disqualifying_eligibility_answer?: false)
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end