require "rails_helper"

RSpec.describe Questions::OtherIncomeTypesController do
  describe ".show?" do
    context "with an intake that reported no other income" do
      let!(:intake) { create :intake, had_other_income: "no" }

      it "returns false" do
        expect(Questions::OtherIncomeTypesController.show?(intake)).to eq false
      end
    end

    context "with an intake that has not filled out the other income column" do
      let!(:intake) { create :intake, had_other_income: "unfilled" }

      it "returns true" do
        expect(Questions::OtherIncomeTypesController.show?(intake)).to eq true
      end
    end

    context "with an intake that reported yes to other income" do
      let!(:intake) { create :intake, had_other_income: "yes" }

      it "returns true" do
        expect(Questions::OtherIncomeTypesController.show?(intake)).to eq true
      end
    end
  end
end

