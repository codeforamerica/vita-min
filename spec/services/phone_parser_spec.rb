require 'rails_helper'

describe PhoneParser do
  describe ".normalize" do
    context "with a US number from California" do
      context "with a +1" do
        it "returns the normalized number" do
          expect(described_class.normalize("+1 (415) 816-1286")).to eq("+14158161286")
        end
      end

      context "without a +1" do
        it "returns the normalized number" do
          expect(described_class.normalize("(415) 816-1286")).to eq("+14158161286")
        end
      end
    end

    context "with a US number from Puerto Rico" do
      context "without a +1" do
        it "returns the normalized number" do
          expect(described_class.normalize("787-764-0000")).to eq("+17877640000")
        end
      end
    end
  end
end
