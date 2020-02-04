require "rails_helper"

RSpec.describe Questions::WidowedYearController do
  describe ".show?" do
    context "with an intake that reported widowed" do
      let!(:intake) { create :intake, widowed: "yes" }

      it "returns true" do
        expect(Questions::WidowedYearController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the widowed column" do
      let!(:intake) { create :intake, widowed: "unfilled" }

      it "returns false" do
        expect(Questions::WidowedYearController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not widowed" do
      let!(:intake) { create :intake, widowed: "no" }

      it "returns false" do
        expect(Questions::WidowedYearController.show?(intake)).to eq false
      end
    end
  end
end

