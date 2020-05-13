require "rails_helper"

RSpec.describe Documents::PriorTaxReturnsController do
  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  describe ".show?" do
    context "when they had a local tax refund" do
      let(:attributes) { { had_local_tax_refund: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they reported an asset sale loss" do
      let(:attributes) { { reported_asset_sale_loss: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        {
          had_local_tax_refund: "no",
          reported_asset_sale_loss: "no",
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

