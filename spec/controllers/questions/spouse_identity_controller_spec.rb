require "rails_helper"

RSpec.describe Questions::SpouseIdentityController, type: :controller do
  describe ".show?" do
    context "with an intake that reported filing_joint" do
      let!(:intake) { create :intake, filing_joint: "yes" }

      it "returns true" do
        expect(Questions::SpouseIdentityController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the filing_joint column" do
      let!(:intake) { create :intake, filing_joint: "unfilled" }

      it "returns false" do
        expect(Questions::SpouseIdentityController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not filing_joint" do
      let!(:intake) { create :intake, filing_joint: "no" }

      it "returns false" do
        expect(Questions::SpouseIdentityController.show?(intake)).to eq false
      end
    end
  end
end