class DfW2Accessor
  include DfXmlCrudMethods

  SELECTORS = {
    EmployeeSSN: 'EmployeeSSN',
    EmployerEIN: 'EmployerEIN',
    EmployerName: 'EmployerName BusinessNameLine1Txt',
    EmployerStateIdNum: 'EmployerStateIdNum',
    AddressLine1Txt: 'EmployerUSAddress AddressLine1Txt',
    City: 'EmployerUSAddress CityNm',
    State: 'EmployerUSAddress StateAbbreviationCd',
    ZIP: 'EmployerUSAddress ZIPCd',
    WagesAmt: 'WagesAmt',
    AllocatedTipsAmt: 'AllocatedTipsAmt',
    DependentCareBenefitsAmt: 'DependentCareBenefitsAmt',
    NonqualifiedPlansAmt: 'NonqualifiedPlansAmt',
    RetirementPlanInd: 'RetirementPlanInd',
    ThirdPartySickPayInd: 'ThirdPartySickPayInd',
    StateAbbreviationCd: 'W2StateTaxGrp StateAbbreviationCd',
    StateWagesAmt: 'W2StateLocalTaxGrp W2StateTaxGrp StateWagesAmt',
    StateIncomeTaxAmt: 'W2StateLocalTaxGrp W2StateTaxGrp StateIncomeTaxAmt',
    LocalWagesAndTipsAmt: 'W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalWagesAndTipsAmt',
    LocalIncomeTaxAmt: 'W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalIncomeTaxAmt',
    LocalityNm: 'W2StateLocalTaxGrp W2StateTaxGrp W2LocalTaxGrp LocalityNm',
    WithholdingAmt: 'WithholdingAmt',
  }

  attr_reader :node

  def initialize(node = nil)
    @node = if node
              node
            else
              Nokogiri::XML(IrsApiService.df_return_sample).at('IRSW2')
            end
  end

  def self.selectors
    SELECTORS
  end
  delegate :selectors, to: :class

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