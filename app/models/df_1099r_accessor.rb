class Df1099rAccessor
  include DfXmlCrudMethods

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

  attr_reader :node

  def self.selectors
    SELECTORS
  end
  delegate :selectors, to: :class

  def initialize(node = nil)
    @node = if node
              node
            else
              Nokogiri::XML(StateFile::XmlReturnSampleService.new.read("az_richard_retirement_1099r")).at('IRS1099R')
            end
  end

  SELECTORS.keys.each do |key|
    if key.ends_with?("Amt")
      define_method(key) do
        df_xml_value(__method__)&.to_i || 0
      end
    else
      define_method(key) do
        df_xml_value(__method__)
      end
    end

    define_method("#{key}=") do |value|
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value)
    end
  end
end