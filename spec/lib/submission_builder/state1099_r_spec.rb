require 'rails_helper'

describe SubmissionBuilder::State1099R do
  StateFile::StateInformationService.active_state_codes.each do |state_code|
    describe ".document" do
      let(:submission) { create(:efile_submission, data_source: intake) }
      let!(:form1099r) do
        create(
          :state_file1099_r,
          intake: intake,
          state_code: state_code.upcase,
          payer_state_code: state_code.upcase
          )
      end
      let(:intake) do
        create("state_file_#{state_code}_intake".to_sym)
      end
      let(:doc) { described_class.new(submission, kwargs: { form1099r: form1099r }).document }

      it "generates xml with the right values" do
        expect(doc.at("PayerNameControlTxt").text).to eq "DORO"
        expect(doc.at("PayerName BusinessNameLine1Txt").text).to eq "Dorothy Red"
        expect(doc.at("PayerUSAddress AddressLine1Txt").text).to eq "123 Sesame ST"
        expect(doc.at("PayerUSAddress AddressLine2Txt").text).to eq "Apt 202"
        expect(doc.at("PayerUSAddress CityNm").text).to eq "Long Island"
        expect(doc.at("PayerUSAddress StateAbbreviationCd").text).to eq "#{state_code.upcase}"
        expect(doc.at("PayerUSAddress ZIPCd").text).to eq "12345"
        expect(doc.at("PayerEIN").text).to eq "22345"
        expect(doc.at("RecipientSSN").text).to eq "123456789"
        expect(doc.at("RecipientNm").text).to eq "Dorothy Jane Red"
        expect(doc.at("GrossDistributionAmt").text).to eq "100"
        expect(doc.at("TaxableAmt").text).to eq "51"
        expect(doc.at("TxblAmountNotDeterminedInd").text).to eq "X"
        expect(doc.at("TotalDistributionInd").text).to eq "X"
        expect(doc.at("FederalIncomeTaxWithheldAmt").text).to eq "11"
        expect(doc.at("F1099RDistributionCd").text).to eq "7"
        expect(doc.at("DesignatedROTHAcctFirstYr").text).to eq "1993"
        expect(doc.at("F1099RStateTaxGrp StateTaxWithheldAmt").text).to eq "51"
        expect(doc.at("F1099RStateTaxGrp StateAbbreviationCd").text).to eq "#{state_code.upcase}"
        expect(doc.at("F1099RStateTaxGrp PayerStateIdNum").text).to eq "#{state_code}12315"
        expect(doc.at("F1099RStateTaxGrp StateDistributionAmt").text).to eq "55"
        expect(doc.at("StandardOrNonStandardCd").text).to eq "N"
      end
    end
  end
end
