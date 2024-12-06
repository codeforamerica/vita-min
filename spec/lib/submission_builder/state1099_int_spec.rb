require 'rails_helper'


describe SubmissionBuilder::State1099Int do
  let(:submission) { create(:efile_submission, data_source: intake) }
  let(:form1099int) { intake.direct_file_json_data.interest_reports.first }
  let(:index) { 0 }
  let(:doc) { described_class.new(submission, kwargs: { form1099int: form1099int, index: index, intake: intake }).document }

  describe "Idaho" do
    let(:intake) { create(:state_file_id_intake, :df_data_1099_int) }

    it "generates xml with the right values" do
      expect(doc.at("PayerName")['payerNameControl']).to eq "BANK"
      expect(doc.at("PayerName/BusinessNameLine1Txt").text).to eq "Bank of Potatoes"
      expect(doc.at("RecipientSSN").text).to eq "400005957"
      expect(doc.at("RecipientName").text).to eq "Miguel Estrada"
      expect(doc.at("InterestIncome").text).to eq "550.0"
      expect(doc.at("InterestOnBondsAndTreasury").text).to eq "50.0"
      expect(doc.at("FederalTaxWithheld").text).to eq "0.0"
      expect(doc.at("TaxExemptInterest").text).to eq "0"
    end

    it "does not add nodes for values that are nil" do
      expect(doc.at("PayerEIN")).to be_nil
      expect(doc.at("TaxExemptCUSIP")).to be_nil
    end
  end

  describe "Arizona" do
    let(:intake) { create(:state_file_az_intake, :df_data_1099_int) }

    it "generates xml with the right values" do
      expect(doc.at("PayerName")['payerNameControl']).to eq "THEP"
      expect(doc.at("PayerName/BusinessNameLine1Txt").text).to eq "The payer name"
      expect(doc.at("RecipientSSN").text).to eq "123456789"
      expect(doc.at("RecipientName").text).to eq "Ariz Onian"
      expect(doc.at("InterestIncome").text).to eq "1.0"
      expect(doc.at("InterestOnBondsAndTreasury").text).to eq "2.0"
      expect(doc.at("FederalTaxWithheld").text).to eq "5.0"
      expect(doc.at("TaxExemptInterest").text).to eq "4.0"
      expect(doc.at("TaxExemptCUSIP").text).to eq "123456789"
    end
  end
end