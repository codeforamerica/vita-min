require 'rails_helper'

describe SubmissionBuilder::State1099G do
  states_using_generic_1099_g = StateFile::StateInformationService.active_state_codes.without("md")
  states_using_generic_1099_g.each do |state_code|
    describe ".document" do
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:recipient) { "primary" }
      let(:had_box_11) { "yes" }
      let(:payer_name) { "Business Geese" }
      let(:payer_street_address) { "123 Duck St" }
      let(:payer_city) { "City" }
      let(:payer_zip) { "11102-1234" }
      let(:payer_tin) { "270293117" }
      let(:unemployment_compensation_amount) { "1" }
      let(:federal_income_tax_withheld_amount) { "0" }
      let(:state_income_tax_withheld_amount) { "0" }
      let(:state_identification_number) { "123456789" }
      let(:recipient_street_address) { "234 Recipient St" }
      let(:recipient_street_address_apartment) { "Unit B" }
      let(:recipient_city) { "City" }
      let(:recipient_zip) { "11102-1234" }
      let(:recipient_state) { "CA" }
      let!(:form1099g) do
        create(
          :state_file1099_g,
          intake: intake,
          recipient: recipient,
          had_box_11: had_box_11,
          payer_name: payer_name,
          payer_street_address: payer_street_address,
          payer_city: payer_city,
          payer_zip: payer_zip,
          payer_tin: payer_tin,
          recipient_city: recipient_city,
          recipient_street_address: recipient_street_address,
          recipient_street_address_apartment: recipient_street_address_apartment,
          recipient_zip: recipient_zip,
          recipient_state: recipient_state,
          unemployment_compensation_amount: unemployment_compensation_amount,
          federal_income_tax_withheld_amount: federal_income_tax_withheld_amount,
          state_income_tax_withheld_amount: state_income_tax_withheld_amount,
          state_identification_number: state_identification_number,
        )
      end
      let(:primary_ssn) { "100000030" }
      let(:primary_first_name) { "Merlin" }
      let(:primary_middle_initial) { "A" }
      let(:primary_last_name) { "Monroe" }
      let(:intake) do
        create(
          "state_file_#{state_code}_intake".to_sym,
          primary_first_name: primary_first_name,
          primary_middle_initial: primary_middle_initial,
          primary_last_name: primary_last_name,
        )
      end
      let(:df_state) { intake.direct_file_data.mailing_state.upcase }
      let(:doc) { described_class.new(submission, kwargs: { form1099g: form1099g }).document }
      before do
        intake.direct_file_data.primary_ssn = primary_ssn
      end

      it "generates xml with the right values" do
        expect(doc.at("PayerName")["payerNameControl"]).to eq "BUSI"
        expect(doc.at("BusinessNameLine1Txt").text).to eq payer_name
        expect(doc.at("PayerUSAddress AddressLine1Txt").text).to eq payer_street_address
        expect(doc.at("PayerUSAddress CityNm").text).to eq payer_city
        expect(doc.at("PayerUSAddress StateAbbreviationCd").text).to eq recipient_state
        expect(doc.at("PayerUSAddress ZIPCd").text).to eq "111021234"
        expect(doc.at("PayerEIN").text).to eq payer_tin
        expect(doc.at("RecipientSSN").text).to eq primary_ssn
        expect(doc.at("RecipientName").text).to eq "Merlin A Monroe"
        expect(doc.at("RecipientUSAddress AddressLine1Txt").text).to eq recipient_street_address
        expect(doc.at("RecipientUSAddress AddressLine2Txt").text).to eq recipient_street_address_apartment
        expect(doc.at("RecipientUSAddress CityNm").text).to eq recipient_city
        expect(doc.at("RecipientUSAddress StateAbbreviationCd").text).to eq recipient_state
        expect(doc.at("RecipientUSAddress ZIPCd").text).to eq "111021234"
        expect(doc.at("UnemploymentCompensation").text).to eq unemployment_compensation_amount
        expect(doc.at("FederalTaxWithheld").text).to eq federal_income_tax_withheld_amount
        expect(doc.at("State1099GStateLocalTaxGrp StateTaxWithheldAmt").text).to eq state_income_tax_withheld_amount
        expect(doc.at("State1099GStateLocalTaxGrp StateAbbreviationCd").text).to eq recipient_state

        expect(doc.at("State1099GStateLocalTaxGrp PayerStateIdNumber").text).to eq state_identification_number
      end
    end
  end
end
