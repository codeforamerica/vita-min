class Df1099rAccessor < DfXmlAccessor
  SELECTORS = {
    payer_name_control: "PayerNameControlTxt",
    payer_name: "PayerName BusinessNameLine1Txt",
    payer_address_line1: "PayerUSAddress AddressLine1Txt",
    payer_address_line2: "PayerUSAddress AddressLine2Txt",
    payer_city_name: "PayerUSAddress CityNm",
    payer_state_code: "PayerUSAddress StateAbbreviationCd",
    payer_zip: "PayerUSAddress ZIPCd",
    payer_identification_number: "PayerEIN",
    phone_number: "PhoneNum",
    gross_distribution_amount: "GrossDistributionAmt",
    taxable_amount: "TaxableAmt",
    federal_income_tax_withheld_amount: "FederalIncomeTaxWithheldAmt",
    distribution_code: "F1099RDistributionCd",
    standard: "StandardOrNonStandardCd",
    state_tax_withheld_amount: "F1099RStateLocalTaxGrp F1099RStateTaxGrp StateTaxWithheldAmt",
    state_code: "F1099RStateLocalTaxGrp F1099RStateTaxGrp StateAbbreviationCd",
    payer_state_identification_number: "F1099RStateLocalTaxGrp F1099RStateTaxGrp PayerStateIdNum",
    state_distribution_amount: "F1099RStateLocalTaxGrp F1099RStateTaxGrp StateDistributionAmt",
    recipient_ssn: "RecipientSSN",
    recipient_name: "RecipientNm",
    taxable_amount_not_determined: "TxblAmountNotDeterminedInd",
    total_distribution: "TotalDistributionInd",
    capital_gain_amount: "CapitalGainAmt",
    designated_roth_account_first_year: "DesignatedROTHAcctFirstYr",
  }

  def self.selectors
    SELECTORS
  end

  def default_node
    Nokogiri::XML(StateFile::DirectFileApiResponseSampleService.new.read_xml("az_richard_retirement_1099r")).at('IRS1099R')
  end

  define_xml_accessors
end