require "rails_helper"

RSpec.describe Documents::Form5498sasController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they had an HSA" do
      let(:attributes) { { had_hsa: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { had_hsa: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

