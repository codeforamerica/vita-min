require 'rails_helper'

describe SubmissionBuilder::State1099Int do
  describe ".document" do
    let(:intake) { create :state_file_md_intake, :df_data_1099_int }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:form1099int) { intake.direct_file_json_data.interest_reports.first }
    let(:index) { 0 }
    let(:doc) { described_class.new(submission, kwargs: { form1099int: form1099int, index: index, intake: intake }).document }

    it "generates xml with the right values" do
      expect(doc.at("PayerName")['payerNameControl']).to eq "THEP"
      expect(doc.at("PayerName/BusinessNameLine1Txt").text).to eq "The payer name"
      expect(doc.at("RecipientSSN").text).to eq "123456789"
      expect(doc.at("RecipientName").text).to eq "Mary A Lando"
      expect(doc.at("InterestIncome").text).to eq "1.0"
      expect(doc.at("InterestOnBondsAndTreasury").text).to eq "2.0"
      expect(doc.at("FederalTaxWithheld").text).to eq "5.0"
      expect(doc.at("TaxExemptInterest").text).to eq "4.0"
      expect(doc.at("TaxExemptCUSIP").text).to eq "123456789"
    end
  end
end
