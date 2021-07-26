require "rails_helper"

describe RrcHelper do
  describe "#calculated_or_provided_dollar_amount" do
    it "returns a formatted dollar amount if it is given a integer value" do
      expect(helper.calculated_or_provided_dollar_amount(1200)).to eq "$1,200"
    end

    context "with Spanish language requested" do
      around do |example|
        I18n.with_locale(:es) { example.run }
      end

      it "return the US English formatted currency anyway" do
        expect(helper.calculated_or_provided_dollar_amount(1200)).to eq "$1,200"
      end
    end

    it "returns a $TBD if it is not given a value" do
      expect(helper.calculated_or_provided_dollar_amount(nil)).to eq "$TBD"
    end
  end
end
