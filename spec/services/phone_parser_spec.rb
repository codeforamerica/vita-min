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

    context "with nil" do
      it "returns nil" do
        expect(described_class.normalize(nil)).to eq(nil)
      end
    end

    context "with empty string" do
      it "returns empty string" do
        expect(described_class.normalize("")).to eq("")
      end
    end

    context "with an invalid, too-short number" do
      it "returns it as-is" do
        expect(described_class.normalize("415")).to eq("415")
      end
    end

    context "with an integer phone number" do
      it "returns the normalized number" do
        expect(described_class.normalize(4158161286)).to eq("+14158161286")
      end
    end
  end

  describe ".formatted_phone_number" do
    it "returns a locally formatted phone number" do
      expect(described_class.formatted_phone_number("4158161286")).to eq "(415) 816-1286"
      expect(described_class.formatted_phone_number("14158161286")).to eq "(415) 816-1286"
    end
  end

  describe ".phone_number_link" do
    it "returns a concise phone number link with country code" do
      expect(described_class.phone_number_link("4158161286")).to eq "tel:+14158161286"
      expect(described_class.phone_number_link("14158161286")).to eq "tel:+14158161286"
    end
  end
end
