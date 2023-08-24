require "rails_helper"

RSpec.describe Questions::SeparatedController, type: :controller do
  describe ".show?" do
    context "with an intake that reported ever_married" do
      let!(:intake) { create :intake, ever_married: "yes" }

      it "returns true" do
        expect(Questions::SeparatedController.show?(intake)).to eq true
      end
    end

    context "with an intake that has not filled out the ever_married column" do
      let!(:intake) { create :intake, ever_married: "unfilled" }

      it "returns false" do
        expect(Questions::SeparatedController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported not ever_married" do
      let!(:intake) { create :intake, ever_married: "no" }

      it "returns false" do
        expect(Questions::SeparatedController.show?(intake)).to eq false
      end
    end
  end
end