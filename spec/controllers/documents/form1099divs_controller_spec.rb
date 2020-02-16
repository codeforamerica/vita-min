require "rails_helper"

RSpec.describe Documents::Form1099divsController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they had dividend income" do
      let(:attributes) { { had_interest_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { had_interest_income: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

