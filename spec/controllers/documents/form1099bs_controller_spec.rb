require "rails_helper"

RSpec.describe Documents::Form1099bsController do
  let(:attributes) { {} }
  let(:intake) { create :intake, **attributes }

  describe ".show?" do
    context "when they had income from sale of stocks, bonds, or real estate" do
      let(:attributes) { { had_asset_sale_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { had_asset_sale_income: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

