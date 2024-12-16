require 'rails_helper'

describe StateFile::NjPropertyTaxFlowHelper do
  describe "#next_controller" do
    context "when return to review" do
      it "returns Nj Review path" do
        options = {return_to_review: "y"}
        expect(described_class.next_controller(options)).to eq("/en/questions/nj-review")
      end
    end

    context "when not return to review" do
      it "returns Nj Estimated Tax Payments path" do
        options = {}
        expect(described_class.next_controller(options)).to eq("/en/questions/nj-estimated-tax-payments")
      end
    end
  end
end