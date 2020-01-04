require "rails_helper"

RSpec.describe Questions::JobCountController do
  describe ".show?" do
    context "with an intake that reported no wages" do
      let!(:intake) { create :intake, had_wages: "no" }

      it "returns false" do
        expect(Questions::JobCountController.show?(intake)).to eq false
      end
    end

    context "with an intake that has not filled out the had_wages column" do
      let!(:intake) { create :intake, had_wages: "unfilled" }

      it "returns true" do
        expect(Questions::JobCountController.show?(intake)).to eq true
      end
    end

    context "with an intake that reported yes to had_wages" do
      let!(:intake) { create :intake, had_wages: "yes" }

      it "returns true" do
        expect(Questions::JobCountController.show?(intake)).to eq true
      end
    end
  end
end

