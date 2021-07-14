require "rails_helper"

describe RrcHelper do
  describe "#calculated_or_provided_dollar_amount" do
    it "returns a formatted dollar amount if it is given a integer value" do
      expect(helper.calculated_or_provided_dollar_amount(1200)).to eq "$1,200"
    end

    it "returns a $TBD if it is not given a value" do
      expect(helper.calculated_or_provided_dollar_amount(nil)).to eq "$TBD"
    end
  end
end
