class DfW2Accessor < DfXmlAccessor
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

  def self.selectors
    SELECTORS
  end

  def default_node
    Nokogiri::XML(IrsApiService.df_return_sample).at('IRSW2')
  end

  define_xml_methods
end