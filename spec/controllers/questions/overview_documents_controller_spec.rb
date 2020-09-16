require "rails_helper"

RSpec.describe Questions::OverviewDocumentsController do
  describe ".show?" do
    context "for intakes with 211 source" do
      let(:intake) { create :intake, source: "211intake" }

      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "for intakes with any other source" do
      let(:intake) { create :intake }

      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end
end