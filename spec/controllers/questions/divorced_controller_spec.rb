require "rails_helper"

RSpec.describe Questions::DivorcedController do
  describe ".show?" do
    context "with an intake that reported yes ever_married" do
      let!(:intake) { create :intake, ever_married: "yes" }

      it "returns true" do
        expect(Questions::DivorcedController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the ever_married column" do
      let!(:intake) { create :intake, ever_married: "unfilled" }

      it "returns false" do
        expect(Questions::DivorcedController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported never married" do
      let!(:intake) { create :intake, ever_married: "no" }

      it "returns true" do
        expect(Questions::DivorcedController.show?(intake)).to eq false
      end
    end
  end
end

