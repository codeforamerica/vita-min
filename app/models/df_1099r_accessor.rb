class Df1099rAccessor < DfXmlAccessor
  SELECTORS = {
    PayerNameControlTxt: "PayerNameControlTxt",
    PayerName: "PayerName BusinessNameLine1Txt",
    PayerAddressLine1Txt: "PayerUSAddress AddressLine1Txt",
    PayerAddressLine2Txt: "PayerUSAddress AddressLine2Txt",
    PayerCityNm: "PayerUSAddress CityNm",
    PayerStateAbbreviationCd: "PayerUSAddress StateAbbreviationCd",
    PayerZIPCd: "PayerUSAddress ZIPCd",
    PayerEIN: "PayerEIN",
    PhoneNum: "PhoneNum",
    GrossDistributionAmt: "GrossDistributionAmt",
    TaxableAmt: "TaxableAmt",
    FederalIncomeTaxWithheldAmt: "FederalIncomeTaxWithheldAmt",
    F1099RDistributionCd: "F1099RDistributionCd",
    StandardOrNonStandardCd: "StandardOrNonStandardCd",
    StateTaxWithheldAmt: "F1099RStateLocalTaxGrp F1099RStateTaxGrp StateTaxWithheldAmt",
    StateAbbreviationCd: "F1099RStateLocalTaxGrp F1099RStateTaxGrp StateAbbreviationCd",
    PayerStateIdNum: "F1099RStateLocalTaxGrp F1099RStateTaxGrp PayerStateIdNum",
    StateDistributionAmt: "F1099RStateLocalTaxGrp F1099RStateTaxGrp StateDistributionAmt",
    RecipientSSN: "RecipientSSN",
    RecipientNm: "RecipientNm",
    TxblAmountNotDeterminedInd: "TxblAmountNotDeterminedInd",
    TotalDistributionInd: "TotalDistributionInd",
    CapitalGainAmt: "CapitalGainAmt",
    DesignatedROTHAcctFirstYr: "DesignatedROTHAcctFirstYr",
  }

  def self.selectors
    SELECTORS
  end

  def default_node
    Nokogiri::XML(StateFile::XmlReturnSampleService.new.read("az_richard_retirement_1099r")).at('IRS1099R')
  end

  define_xml_accessors
end