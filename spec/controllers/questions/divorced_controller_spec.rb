require "rails_helper"

RSpec.describe Questions::DivorcedController do
  describe ".show?" do
    context "with an intake that reported married" do
      let!(:intake) { create :intake, married: "yes" }

      it "returns false" do
        expect(Questions::DivorcedController.show?(intake)).to eq false
      end
    end

    context "with an intake that has not filled out the married column" do
      let!(:intake) { create :intake, married: "unfilled" }

      it "returns false" do
        expect(Questions::DivorcedController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not married" do
      let!(:intake) { create :intake, married: "no" }

      it "returns true" do
        expect(Questions::DivorcedController.show?(intake)).to eq true
      end
    end
  end
end

