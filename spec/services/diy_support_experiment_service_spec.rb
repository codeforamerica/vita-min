require 'rails_helper'

describe DiySupportExperimentService do
  describe ".taxslayer_link" do
    scenarios = [
      { received_1099: :ignored_because_treatment_nil, support_level_treatment: nil, link: "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=01011934"},
      { received_1099: true, support_level_treatment: "high", link: "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23062996"},
      { received_1099: true, support_level_treatment: "not-high", link: "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=34067601"},
      { received_1099: false, support_level_treatment: "high", link: "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=23069434"},
      { received_1099: false, support_level_treatment: "not-high", link: "https://www.taxslayer.com/v.aspx?rdr=/vitafsa&source=TSUSATY2022&sidn=21061019"},
    ]

    scenarios.each do |scenario|
      received_1099 = scenario[:received_1099]
      support_level_treatment = scenario[:support_level_treatment]
      expected_link = scenario[:link]
      context "Given received_1099=#{received_1099} and support_level_treatment=#{support_level_treatment}" do
        it "returns the expected link" do
          expect(described_class.taxslayer_link(support_level_treatment, received_1099)).to eq(expected_link)
        end
      end
    end
  end
end
