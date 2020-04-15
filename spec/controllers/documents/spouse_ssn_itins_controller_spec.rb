require "rails_helper"

RSpec.describe Documents::SpouseSsnItinsController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they are filing jointly" do
      let(:attributes) { { filing_joint: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they are not filing jointly" do
      let(:attributes) { { filing_joint: "no" } }

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

