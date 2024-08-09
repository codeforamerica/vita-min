class Df1099rAccessor < DfXmlAccessor
  SELECTORS = {
    PayerNameControlTxt: "PayerNameControlTxt",
    PayerName: "PayerName BusinessNameLine1Txt",
    AddressLine1Txt: "PayerUSAddress AddressLine1Txt",
    CityNm: "PayerUSAddress CityNm",
    StateAbbreviationCd: "PayerUSAddress StateAbbreviationCd",
    ZIPCd: "PayerUSAddress ZIPCd",
    PayerEIN: "PayerEIN",
    PhoneNum: "PhoneNum",
    GrossDistributionAmt: "GrossDistributionAmt",
    TaxableAmt: "TaxableAmt",
    FederalIncomeTaxWithheldAmt: "FederalIncomeTaxWithheldAmt",
    F1099RDistributionCd: "F1099RDistributionCd",
    StandardOrNonStandardCd: "StandardOrNonStandardCd",
  }

  def self.selectors
    SELECTORS
  end

  def default_node
    Nokogiri::XML(StateFile::XmlReturnSampleService.new.read("az_richard_retirement_1099r")).at('IRS1099R')
  end

  define_xml_methods
end