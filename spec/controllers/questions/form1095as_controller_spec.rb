require "rails_helper"

RSpec.describe Questions::Form1095asController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they purchased health insurance" do
      let(:attributes) { { bought_health_insurance: "yes" } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { bought_health_insurance: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

