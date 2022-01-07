require "rails_helper"

RSpec.describe PhoneNumberHelper do
  describe "#formatted_phone_number" do
    before do
      allow(PhoneParser).to receive(:formatted_phone_number).and_return("(415) 816-1286")
    end

    it "returns a locally formatted phone number" do
      expect(helper.formatted_phone_number("4158161286")).to eq "(415) 816-1286"
      expect(PhoneParser).to have_received(:formatted_phone_number).with("4158161286")
    end
  end

  describe "#phone_number_link" do
    before do
      allow(PhoneParser).to receive(:phone_number_link).and_return("tel:+14158161286")
    end

    it "returns a phone number link" do
      expect(helper.phone_number_link("4158161286")).to eq "tel:+14158161286"
      expect(PhoneParser).to have_received(:phone_number_link).with("4158161286")
    end
  end
end
