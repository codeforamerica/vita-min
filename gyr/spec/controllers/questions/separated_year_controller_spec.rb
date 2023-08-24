require "rails_helper"

RSpec.describe Questions::SeparatedYearController do
  describe ".show?" do
    context "with an intake that reported separated" do
      let!(:intake) { create :intake, separated: "yes" }

      it "returns true" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the separated column" do
      let!(:intake) { create :intake, separated: "unfilled" }

      it "returns false" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not separated" do
      let!(:intake) { create :intake, separated: "no" }

      it "returns false" do
        expect(Questions::SeparatedYearController.show?(intake)).to eq false
      end
    end
  end
end

