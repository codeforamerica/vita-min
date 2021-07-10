require "rails_helper"

describe ApplicationHelper do
  describe "#mask" do
    context "without a character parameter" do
      it "masks all of the digits by default" do
        expect(mask("TESTTEST")).to eq '●●●●●●●●'
      end
    end

    it "masks the string with little dots except for the number of characters indicated" do
      expect(mask("TESTTEST", 5)).to eq '●●●TTEST'
    end

    it "does not break when the string is empty" do
      expect(mask("")).to eq ""
    end

    it "does not break when the param is nil" do
      expect(mask(nil)).to eq nil
    end

  end
end