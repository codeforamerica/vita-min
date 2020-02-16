require "rails_helper"

RSpec.describe Documents::Form1099ssdisController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they had disability income" do
      let(:attributes) { { had_disability_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { had_disability_income: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

