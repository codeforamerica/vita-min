require "rails_helper"

describe FraudIndicatorsHelper do
  describe 'link_to_indicator_list' do
    context "when passed a fraud indicator without a list model type" do
      let(:indicator) { create :fraud_indicator, list_model_name: nil }
      it "returns nil" do
        expect(link_to_indicator_list(indicator)).to eq nil
      end
    end

    context "when the indicator type is not in the list" do
      let(:indicator) { build :fraud_indicator, list_model_name: "Fraud::Indicators::Something", indicator_type: "duplicates"}
      it "returns nil" do
        expect(link_to_indicator_list(indicator)).to eq nil
      end
    end

    context "when a route for the indicator does not exist" do
      let(:indicator) { build :fraud_indicator, list_model_name: "Fraud::Indicators::Something", indicator_type: "not_in_safelist"}
      it "returns nil" do
        expect(link_to_indicator_list(indicator)).to eq nil
      end
    end

    context "when a route for the indicator exists" do
      context "hub_risky_domains" do
        let(:indicator) { build :fraud_indicator, list_model_name: "Fraud::Indicators::Domain", indicator_type: "in_riskylist" }
        it "returns a link to the page" do
          expect(link_to_indicator_list(indicator)).to eq "<a href=\"/en/hub/fraud-indicators/risky-domains\"><i class=\"icon-\">list_alt</i></a>"
        end
      end

      context "hub_timezones" do
        let(:indicator) { build :fraud_indicator, list_model_name: "Fraud::Indicator::Timezone", indicator_type: "in_riskylist" }
        it "returns a link to the page" do
          expect(link_to_indicator_list(indicator)).to eq "<a href=\"/en/hub/fraud-indicators/timezones\"><i class=\"icon-\">list_alt</i></a>"
        end
      end
    end
  end

  describe "to_id_name" do
    context "when initialized with nil" do
      it "returns an empty string" do
        expect(to_id_name(nil)).to eq ""
      end
    end

    context "with slashes and periods" do
      it "removes everything after the period and changes slashes to dashes + downcases" do
        expect(to_id_name("America/Chicago.com")).to eq "america-chicago"
      end
    end
  end
end