require "rails_helper"

RSpec.describe PhoneNumberHelper do
  describe "#local_phone_number" do
    it "returns a locally formatted phone number" do
      expect(helper.local_phone_number("4158161286")).to eq "(415) 816-1286"
      expect(helper.local_phone_number("14158161286")).to eq "(415) 816-1286"
    end
  end
end