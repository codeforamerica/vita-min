require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::Documents::Md1099G do
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
    let(:recipient_state) { "CA" }
    let(:recipient_zip) { "11102-1234" }
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
        "state_file_md_intake".to_sym,
        primary_first_name: primary_first_name,
        primary_middle_initial: primary_middle_initial,
        primary_last_name: primary_last_name,
        )
    end
    let(:doc) { described_class.new(submission, kwargs: { form1099g: form1099g }).document }
    before do
      intake.direct_file_data.primary_ssn = primary_ssn
    end

    it "generates xml with the right values" do
      expect(doc.at("BusinessNameLine1Txt").text).to eq payer_name
      expect(doc.at("Payer Address AddressLine1Txt").text).to eq payer_street_address
      expect(doc.at("Payer Address CityNm").text).to eq payer_city
      expect(doc.at("Payer Address StateAbbreviationCd").text).to eq "MD"
      expect(doc.at("Payer Address ZIPCd").text).to eq "111021234"
      expect(doc.at("Payer IDNumber").text).to eq payer_tin
      expect(doc.at("Recipient SSN").text).to eq primary_ssn
      expect(doc.at("Recipient Name").text).to eq "Merlin A Monroe"
      expect(doc.at("Recipient Address USAddress AddressLine1Txt").text).to eq recipient_street_address
      expect(doc.at("Recipient Address USAddress AddressLine2Txt").text).to eq recipient_street_address_apartment
      expect(doc.at("Recipient Address USAddress CityNm").text).to eq recipient_city
      expect(doc.at("Recipient Address USAddress StateAbbreviationCd").text).to eq recipient_state
      expect(doc.at("Recipient Address USAddress ZIPCd").text).to eq "111021234"
      expect(doc.at("UnemploymentCompensationPaid").text).to eq unemployment_compensation_amount
      expect(doc.at("FederalTaxWithheld").text).to eq federal_income_tax_withheld_amount
      expect(doc.at("StateTaxWithheld").text).to eq state_income_tax_withheld_amount
    end
  end
end
