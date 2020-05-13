require "rails_helper"

RSpec.describe Documents::Form1099ssController do
  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  describe ".show?" do
    context "when they sold a home" do
      let(:attributes) { { sold_a_home: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they sold other assets" do
      let(:attributes) { { had_asset_sale_income: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        {
          had_asset_sale_income: "no",
          sold_a_home: "unfilled"
        }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end

