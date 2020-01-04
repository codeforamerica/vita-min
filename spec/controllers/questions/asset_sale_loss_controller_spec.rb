require "rails_helper"

RSpec.describe Questions::AssetSaleLossController do
  describe ".show?" do
    context "with an intake that reported no asset sale" do
      let!(:intake) { create :intake, had_asset_sale_income: "no" }

      it "returns false" do
        expect(Questions::AssetSaleLossController.show?(intake)).to eq false
      end
    end

    context "with an intake that has not filled out the asset sale column" do
      let!(:intake) { create :intake, had_asset_sale_income: "unfilled" }

      it "returns true" do
        expect(Questions::AssetSaleLossController.show?(intake)).to eq true
      end
    end

    context "with an intake that reported yes to an asset sale" do
      let!(:intake) { create :intake, had_asset_sale_income: "yes" }

      it "returns true" do
        expect(Questions::AssetSaleLossController.show?(intake)).to eq true
      end
    end
  end
end

