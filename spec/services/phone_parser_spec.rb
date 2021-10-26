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
  end

  describe ".formatted_phone_number" do
    it "returns a locally formatted phone number" do
      expect(described_class.formatted_phone_number("4158161286")).to eq "(415) 816-1286"
      expect(described_class.formatted_phone_number("14158161286")).to eq "(415) 816-1286"
    end
  end

  describe ".with_country_code" do
    it "returns a concise phone number with country code" do
      expect(described_class.with_country_code("4158161286")).to eq "14158161286"
      expect(described_class.with_country_code("14158161286")).to eq "14158161286"
    end
  end

  describe ".valid?" do
    context "with a valid e164 Twilio US format phone number" do
      let(:value) { "+15005550006" }

      it "does not add an error" do
        expect(described_class.valid?(value)).to eq(true)
      end
    end

    context "with an e164 number lacking a plus sign" do
      let(:value) { "15005550006" }

      it "adds an error" do
        expect(described_class.valid?(value)).to eq(false)
      end
    end

    context "with a valid non-e164 format phone number" do
      let(:value) { "(500) 555-0006" }

      it "adds an error" do
        expect(described_class.valid?(value)).to eq(false)
      end
    end

    context "with a clearly invalid phone number" do
      let(:value) { "653423" }

      it "adds an error" do
        expect(record.errors[:phone_number]).to eq(["Please enter a valid phone number."])
      end
    end

    context "with a blank value" do
      let(:value) { " " }

      it "adds an error" do
        expect(record.errors[:phone_number]).to eq(["Please enter a valid phone number."])
      end
    end
  end
end
