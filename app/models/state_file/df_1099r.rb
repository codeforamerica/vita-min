module StateFile
  class Df1099R
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

    def selectors
      SELECTORS
    end

    def initialize(node = nil)
      @node = if node
                node
              else
                Nokogiri::XML(StateFile::XmlReturnSampleService.new.read("az_richard_retirement_1099r")).at('IRS1099R')
              end
    end

    def PayerNameControlTxt
      df_xml_value(__method__)
    end

    def PayerNameControlTxt=(value)
      write_df_xml_value(__method__, value)
    end

    def PayerName
      df_xml_value(__method__)
    end

    def PayerName=(value)
      write_df_xml_value(__method__, value)
    end

    def AddressLine1Txt
      df_xml_value(__method__)
    end

    def AddressLine1Txt=(value)
      write_df_xml_value(__method__, value)
    end

    def CityNm
      df_xml_value(__method__)
    end

    def CityNm=(value)
      write_df_xml_value(__method__, value)
    end

    def StateAbbreviationCd
      df_xml_value(__method__)
    end

    def StateAbbreviationCd=(value)
      write_df_xml_value(__method__, value)
    end

    def ZIPCd
      df_xml_value(__method__)
    end

    def ZIPCd=(value)
      write_df_xml_value(__method__, value)
    end

    def PayerEIN
      df_xml_value(__method__)
    end

    def PayerEIN=(value)
      write_df_xml_value(__method__, value)
    end

    def PhoneNum
      df_xml_value(__method__)
    end

    def PhoneNum=(value)
      write_df_xml_value(__method__, value)
    end

    def GrossDistributionAmt
      df_xml_value(__method__)
    end

    def GrossDistributionAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def TaxableAmt
      df_xml_value(__method__)
    end

    def TaxableAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def FederalIncomeTaxWithheldAmt
      df_xml_value(__method__)
    end

    def FederalIncomeTaxWithheldAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def F1099RDistributionCd
      df_xml_value(__method__)
    end

    def F1099RDistributionCd=(value)
      write_df_xml_value(__method__, value)
    end

    def StandardOrNonStandardCd
      df_xml_value(__method__)
    end

    def StandardOrNonStandardCd=(value)
      write_df_xml_value(__method__, value)
    end
  end
end
