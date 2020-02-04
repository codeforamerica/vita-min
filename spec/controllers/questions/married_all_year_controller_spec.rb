require "rails_helper"

RSpec.describe Questions::MarriedAllYearController, type: :controller do
  describe ".show?" do
    context "with an intake that reported married" do
      let!(:intake) { create :intake, married: "yes" }

      it "returns true" do
        expect(Questions::MarriedAllYearController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the married column" do
      let!(:intake) { create :intake, married: "unfilled" }

      it "returns false" do
        expect(Questions::MarriedAllYearController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not married" do
      let!(:intake) { create :intake, married: "no" }

      it "returns false" do
        expect(Questions::MarriedAllYearController.show?(intake)).to eq false
      end
    end
  end
end
