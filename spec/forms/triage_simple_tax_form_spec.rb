require "rails_helper"

describe TriageSimpleTaxForm do
  subject { described_class.new(params) }
  let(:has_simple_taxes) { "yes" }
  let(:params) do
    {
        has_simple_taxes: has_simple_taxes
    }
  end

  context "an instance" do
    it "responds to #has_simple_taxes" do
      expect(subject).to respond_to :has_simple_taxes
    end
  end

  describe "#has_simple_taxes?" do
    context "has_simple_taxes is yes" do
      it "is true" do
        expect(subject.has_simple_taxes?).to eq true
      end
    end

    context "has_simple_taxes is no" do
      let(:has_simple_taxes) { "no" }
      it "is false" do
        expect(subject.has_simple_taxes?).to eq false
      end
    end
  end
end