require "rails_helper"

RSpec.describe Documents::Form1098sController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they paid mortgage interest" do
      let(:attributes) { { paid_mortgage_interest: "yes" } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they paid local taxes" do
      let(:attributes) { { paid_local_tax: "yes" } }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        {
          paid_mortgage_interest: "no",
          paid_local_tax: "unfilled",
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

