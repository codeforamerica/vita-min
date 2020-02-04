require "rails_helper"

RSpec.describe Questions::DivorcedYearController do
  describe ".show?" do
    context "with an intake that reported divorced" do
      let!(:intake) { create :intake, divorced: "yes" }

      it "returns true" do
        expect(Questions::DivorcedYearController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the divorced column" do
      let!(:intake) { create :intake, divorced: "unfilled" }

      it "returns false" do
        expect(Questions::DivorcedYearController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not divorced" do
      let!(:intake) { create :intake, divorced: "no" }

      it "returns false" do
        expect(Questions::DivorcedYearController.show?(intake)).to eq false
      end
    end
  end
end

