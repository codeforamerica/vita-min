require "rails_helper"

RSpec.describe Questions::SeparatedYearController do
  describe ".show?" do
    context "with an intake that reported separated" do
      let!(:intake) { create :intake, married: "yes", separated: "yes" }

      it "returns true" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the separated column" do
      let!(:intake) { create :intake, married: "yes", separated: "unfilled" }

      it "returns true" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq true
      end
    end

    context "with an intake that reported not separated" do
      let!(:intake) { create :intake, married: "yes", separated: "no" }

      it "returns false" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not married" do
      let!(:intake) { create :intake, married: "no" }

      it "returns false" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq false
      end
    end
  end
end

