require "rails_helper"

RSpec.describe Questions::SelfEmploymentLossController do
  describe ".show?" do
    context "with an intake that reported no self employment income" do
      let!(:intake) { create :intake, had_self_employment_income: "no" }

      it "returns false" do
        expect(Questions::SelfEmploymentLossController.show?(intake)).to eq false
      end
    end

    context "with an intake that has not filled out the self employment income column" do
      let!(:intake) { create :intake, had_self_employment_income: "unfilled" }

      it "returns true" do
        expect(Questions::SelfEmploymentLossController.show?(intake)).to eq true
      end
    end

    context "with an intake that reported yes to self employment income" do
      let!(:intake) { create :intake, had_self_employment_income: "yes" }

      it "returns true" do
        expect(Questions::SelfEmploymentLossController.show?(intake)).to eq true
      end
    end
  end
end

