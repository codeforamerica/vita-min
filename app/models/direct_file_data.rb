class DirectFileData
  include DfXmlCrudMethods

  SELECTORS = {
    tax_return_year: 'ReturnHeader TaxYr',
    filing_status: 'IRS1040 IndividualReturnFilingStatusCd',
    primary_ssn: 'ReturnHeader Filer PrimarySSN',
    primary_occupation: 'IRS1040 PrimaryOccupationTxt',
    spouse_ssn: 'ReturnHeader Filer SpouseSSN',
    spouse_occupation: 'IRS1040 SpouseOccupationTxt',
    mailing_city: 'ReturnHeader Filer USAddress CityNm',
    mailing_street: 'ReturnHeader Filer USAddress AddressLine1Txt',
    mailing_apartment: 'ReturnHeader Filer USAddress AddressLine2Txt',
    mailing_state: 'ReturnHeader Filer USAddress StateAbbreviationCd',
    mailing_zip: 'ReturnHeader Filer USAddress ZIPCd',
    phone_number: 'ReturnHeader Filer PhoneNum',
    cell_phone_number: 'ReturnHeader AdditionalFilerInformation AtSubmissionFilingGrp CellPhoneNum',
    tax_payer_email: 'ReturnHeader AdditionalFilerInformation AtSubmissionFilingGrp EmailAddressTxt',
    fed_tax: 'IRS1040 TotalTaxBeforeCrAndOthTaxesAmt',
    fed_agi: 'IRS1040 AdjustedGrossIncomeAmt',
    fed_wages: 'IRS1040 WagesAmt',
    fed_wages_salaries_tips: 'IRS1040 WagesSalariesAndTipsAmt',
    fed_taxable_income: 'IRS1040 TaxableInterestAmt',
    fed_educator_expenses: 'IRS1040Schedule1 EducatorExpensesAmt',
    fed_student_loan_interest: 'IRS1040Schedule1 StudentLoanInterestDedAmt',
    fed_total_adjustments: 'IRS1040Schedule1 TotalAdjustmentsAmt',
    fed_taxable_ssb: 'IRS1040 TaxableSocSecAmt',
    fed_ssb: 'IRS1040 SocSecBnftAmt',
    fed_eic: 'IRS1040 EarnedIncomeCreditAmt',
    fed_puerto_rico_income_exclusion_amount: "IRS1040 ExcldSect933PuertoRicoIncmAmt",
    total_exempt_primary_spouse: 'IRS1040 TotalExemptPrimaryAndSpouseCnt',
    fed_irs_1040_nr: 'IRS1040NR',
    fed_unemployment: 'IRS1040Schedule1 UnemploymentCompAmt',
    fed_housing_deduction_amount: 'IRS1040Schedule1 HousingDeductionAmt',
    fed_gross_income_exclusion_amount: 'IRS1040Schedule1 GrossIncomeExclusionAmt',
    fed_total_income_exclusion_amount: 'IRS1040Schedule1 TotalIncomeExclusionAmt',
    fed_foreign_tax_credit_amount: 'IRS1040Schedule3 ForeignTaxCreditAmt',
    fed_credit_for_child_and_dependent_care_amount: 'IRS1040Schedule3 CreditForChildAndDepdCareAmt',
    fed_education_credit_amount: 'IRS1040Schedule3 EducationCreditAmt',
    fed_retirement_savings_contribution_credit_amount: 'IRS1040Schedule3 RtrSavingsContributionsCrAmt',
    fed_energy_efficiency_home_improvement_credit_amount: 'IRS1040Schedule3 EgyEffcntHmImprvCrAmt',
    fed_credit_for_elderly_or_disabled_amount: 'IRS1040Schedule3 CreditForElderlyOrDisabledAmt',
    fed_clean_vehicle_personal_use_credit_amount: 'IRS1040Schedule3 CleanVehPrsnlUsePartCrAmt',
    fed_total_reporting_year_tax_increase_or_decrease_amount: 'IRS1040Schedule3 TotRptgYrTxIncreaseDecreaseAmt',
    fed_previous_owned_clean_vehicle_credit_amount: 'IRS1040Schedule3 MaxPrevOwnedCleanVehCrAmt',
    fed_calculated_difference_amount: 'IRS1040Schedule8812 ClaimACTCAllFilersGrp CalculatedDifferenceAmt',
    fed_nontaxable_combat_pay_amount: 'IRS1040Schedule8812 ClaimACTCAllFilersGrp NontaxableCombatPayAmt',
    fed_total_earned_income_amount: 'IRS1040Schedule8812 ClaimACTCAllFilersGrp TotalEarnedIncomeAmt',
    fed_ctc: 'IRS1040Schedule8812 AdditionalChildTaxCreditAmt',
    fed_qualify_child: 'IRS1040Schedule8812 QlfyChildUnderAgeSSNLimtAmt',
    fed_residential_clean_energy_credit_amount: 'IRS5695 ResidentialCleanEnergyCrAmt',
    fed_mortgage_interest_credit_amount: 'IRS8396 MortgageInterestCreditAmt',
    fed_adoption_credit_amount: 'IRS8839 AdoptionCreditAmt',
    fed_dc_homebuyer_credit_amount: 'IRS8859 DCHmByrCurrentYearCreditAmt',
    fed_w2_state: 'W2StateLocalTaxGrp W2StateTaxGrp StateAbbreviationCd',
    primary_claim_as_dependent: 'IRS1040 PrimaryClaimAsDependentInd',
    hoh_qualifying_person_name: 'IRS1040 QualifyingHOHNm'
  }.freeze

  def initialize(raw_xml)
    @raw_xml = raw_xml
  end

  def selectors
    SELECTORS
  end

  def parsed_xml
    @parsed_xml ||= Nokogiri::XML(@raw_xml)
  end

  def node
    parsed_xml
  end

  def to_s
    parsed_xml.to_s
  end

  def tax_return_year
    df_xml_value(__method__)&.to_i
  end

  def filing_status
    df_xml_value(__method__)&.to_i
  end

  def filing_status=(value)
    write_df_xml_value(__method__, value)
  end

  def phone_number
    df_xml_value(__method__)
  end

  def cell_phone_number
    df_xml_value(__method__)
  end

  def tax_payer_email
    df_xml_value(__method__)
  end

  def primary_ssn
    df_xml_value(__method__)
  end

  def primary_ssn=(value)
    write_df_xml_value(__method__, value)
  end

  def primary_occupation
    df_xml_value(__method__)
  end

  def primary_occupation=(value)
    write_df_xml_value(__method__, value)
  end

  def spouse_ssn
    df_xml_value(__method__)
  end

  def spouse_ssn=(value)
    create_or_destroy_df_xml_node(__method__, value, after="PrimarySSN")

    if value.present?
      write_df_xml_value(__method__, value)
    end
  end

  def spouse_occupation
    df_xml_value(__method__)
  end

  def spouse_occupation=(value)
    create_or_destroy_df_xml_node(__method__, value, after="PrimaryOccupationTxt")

    if value.present?
      write_df_xml_value(__method__, value)
    end
  end

  def mailing_city
    df_xml_value(__method__)
  end

  def mailing_city=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_street
    df_xml_value(__method__)
  end

  def mailing_street=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_apartment
    df_xml_value(__method__)
  end

  def mailing_state
    df_xml_value(__method__)
  end

  def mailing_state=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_zip
    df_xml_value(__method__)
  end

  def mailing_zip=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_tax
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_tax=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_agi
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_agi=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_wages
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_wages=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_wages_salaries_tips
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_taxable_income
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_taxable_income=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_unemployment
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_unemployment=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_taxable_ssb
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_taxable_ssb=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_ssb
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_ssb=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_non_taxable_ssb
    fed_ssb - fed_taxable_ssb
  end

  def fed_adjustments_claimed
    adjustments = {
      fed_educator_expenses: {
        pdf_label: "ed expenses",
        xml_label: "Educator Expenses"
      },
      fed_student_loan_interest: {
        pdf_label: "stud loan ded",
        xml_label: "Student Loan Interest Deduction"
      }
    }
    adjustments.keys.each { |k| adjustments[k][:amount] = df_xml_value(k)&.to_i || 0 }
    adjustments.select { |k, info| info[:amount].present? && info[:amount] > 0 }
  end

  def fed_total_adjustments
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_total_adjustments=(value)
    write_df_xml_value(__method__, value)
  end

  def total_state_tax_withheld
    total = 0
    parsed_xml.css('IRSW2').map do |w2|
      amt = w2.at('StateIncomeTaxAmt')&.text.to_i
      total += amt
    end
    total
  end

  def total_local_tax_withheld
    total = 0
    parsed_xml.css('IRSW2').map do |w2|
      amt = w2.at('LocalIncomeTaxAmt')&.text.to_i
      total += amt
    end
    total
  end

  def fed_ctc_claimed
    (fed_ctc || 0).positive? || (fed_qualify_child || 0).positive?
  end

  def fed_ctc
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_ctc=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_qualify_child
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_qualify_child=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_calculated_difference_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_calculated_difference_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_nontaxable_combat_pay_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_nontaxable_combat_pay_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_earned_income_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_total_earned_income_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_puerto_rico_income_exclusion_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_puerto_rico_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_income_exclusion_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_total_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_housing_deduction_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_housing_deduction_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_gross_income_exclusion_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_gross_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_mortgage_interest_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_mortgage_interest_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_dc_homebuyer_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_dc_homebuyer_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_residential_clean_energy_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_residential_clean_energy_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_adoption_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_adoption_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_foreign_tax_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_foreign_tax_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_credit_for_child_and_dependent_care_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_credit_for_child_and_dependent_care_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_education_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_education_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_retirement_savings_contribution_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_retirement_savings_contribution_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_energy_efficiency_home_improvement_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_energy_efficiency_home_improvement_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_credit_for_elderly_or_disabled_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_credit_for_elderly_or_disabled_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_clean_vehicle_personal_use_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_clean_vehicle_personal_use_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_reporting_year_tax_increase_or_decrease_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_total_reporting_year_tax_increase_or_decrease_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_previous_owned_clean_vehicle_credit_amount
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_previous_owned_clean_vehicle_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_irs_1040_nr_filed
    fed_irs_1040_nr.present?
  end

  def fed_irs_1040_nr
    df_xml_value(__method__)
  end

  def fed_eic_claimed
    (fed_eic || 0).positive?
  end

  def fed_eic
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_eic_qc_claimed
    parsed_xml.at('IRS1040ScheduleEIC QualifyingChildInformation') != nil
  end

  def total_exempt_primary_spouse
    df_xml_value(__method__).to_i
  end

  def total_exempt_primary_spouse=(value)
    write_df_xml_value(__method__, value.to_i)
  end

  def claimed_as_dependent?
    primary_claim_as_dependent == "X"
  end

  def primary_claim_as_dependent
    df_xml_value(__method__)
  end

  def primary_claim_as_dependent=(value)
    create_or_destroy_df_xml_node(__method__, true, 'VirtualCurAcquiredDurTYInd')
    write_df_xml_value(__method__, value)
  end

  def hoh_qualifying_person_name
    df_xml_value(__method__)
  end

  def hoh_qualifying_person_name=(value)
    create_or_destroy_df_xml_node(__method__, true, 'SpouseNm')
    write_df_xml_value(__method__, value)
  end

  def primary_has_itin?
    primary_ssn.start_with?("9")
  end

  def fed_65_primary_spouse
    elements_to_check = ['Primary65OrOlderInd', 'Spouse65OrOlderInd']
    value = 0

    elements_to_check.each do |element_name|
      if parsed_xml.at(element_name)
        value += 1
      end
    end
    value
  end

  def fed_w2_state
    df_xml_value(__method__)
  end

  def fed_w2_state=(value)
    write_df_xml_value(__method__, value)
  end

  def blind_primary_spouse
    elements_to_check = ['PrimaryBlindInd', 'SpouseBlindInd']
    value = 0

    elements_to_check.each do |element_name|
      if parsed_xml.at(element_name)
        value += 1
      end
    end
    value
  end

  def ny_public_employee_retirement_contributions
    box14_total = 0
    retirement_types = ['414(H)', '414HCU', 'ERSNYSRE', 'NYSERS', 'RET', 'RETSH', 'TIER3RET', '414(H)CU', '414HSUB', 'ERSRETCO', 'NYSRETCO', 'RETDEF', 'RETSM', 'TIER4', '414H', 'ERS', 'NYRET', 'PUBRET', 'RETMT', 'TIER4RET', 'RETSUM']

    parsed_xml.css('IRSW2 OtherDeductionsBenefitsGrp').map do |deduction|
      desc = deduction.at('Desc')&.text
      amt = deduction.at('Amt')&.text.to_i

      if retirement_types.include?(desc.upcase.gsub(/\s/, ''))
        box14_total += amt
      end
    end

    box14_total
  end

  def dependent_detail_nodes
    parsed_xml.css('DependentDetail')
  end

  def build_new_dependent_detail_node
    dd = parsed_xml.css('DependentDetail').first
    parsed_xml.css('DependentDetail').last.add_next_sibling(dd.to_s)
  end

  def qualifying_child_information_nodes
    parsed_xml.css('QualifyingChildInformation')
  end

  def eitc_eligible_nodes
    parsed_xml.css('IRS1040ScheduleEIC QualifyingChildInformation')
  end

  def build_new_qualifying_child_information_node
    dd = parsed_xml.css('QualifyingChildInformation').first
    parsed_xml.css('QualifyingChildInformation').last.add_next_sibling(dd.to_s)
  end

  def w2_nodes
    parsed_xml.css('IRSW2')
  end

  def w2s
    parsed_xml.css('IRSW2').map do |node|
      DfW2.new(node)
    end
  end

  def build_new_w2_node
    w2 = parsed_xml.css('IRSW2').first
    parsed_xml.css('IRSW2').last.add_next_sibling(w2.to_s)
  end

  def eitc_eligible_dependents
    @eligible_dependents ||= Hash.new{}
    eitc_eligible_nodes.map { |node| @eligible_dependents[node.at('QualifyingChildSSN')&.text] = node }
    @eligible_dependents
  end

  def dependents
    return @dependents if @dependents

    @dependents = []
    dependent_detail_nodes.each do |node|
      ssn = node.at('DependentSSN')&.text
      dependent = Dependent.new(
        first_name: node.at('DependentFirstNm')&.text,
        last_name: node.at('DependentLastNm')&.text,
        ssn: ssn,
        relationship: node.at('DependentRelationshipCd')&.text,
      )

      eitc_dependent_node = eitc_eligible_dependents[ssn]
      if eitc_dependent_node.present?
        dependent.eic_qualifying = true
        unless self.mailing_state == 'AZ'
          dependent.months_in_home = eitc_dependent_node.at('MonthsChildLivedWithYouCnt')&.text.to_i
        end
        dependent.eic_student = determine_eic_attribute(eitc_dependent_node.at('ChildIsAStudentUnder24Ind')&.text)
        dependent.eic_disability = determine_eic_attribute(eitc_dependent_node.at('ChildPermanentlyDisabledInd')&.text)
      else
        dependent.eic_qualifying = false
        dependent.eic_student = 'unfilled'
        dependent.eic_disability = 'unfilled'
      end

      dependent.ctc_qualifying = node.at('EligibleForChildTaxCreditInd')&.text == 'X'
      dependent.odc_qualifying = node.at('EligibleForODCInd')&.text == 'X'
      @dependents << dependent
    end
    @dependents
  end

  def determine_eic_attribute(node)
    case node
    when 'true'
      'yes'
    when 'false'
      'no'
    else
      'unfilled'
    end
  end
    
  class DfW2
    include DfXmlCrudMethods

    SELECTORS = {
      EmployeeSSN: 'EmployeeSSN',
      EmployerEIN: 'EmployerEIN',
      EmployerName: 'EmployerName BusinessNameLine1Txt',
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
      StateWagesAmt: 'W2StateTaxGrp StateWagesAmt',
      StateIncomeTaxAmt: 'W2StateTaxGrp StateIncomeTaxAmt',
      LocalWagesAndTipsAmt: 'W2LocalTaxGrp LocalWagesAndTipsAmt',
      LocalIncomeTaxAmt: 'W2LocalTaxGrp LocalIncomeTaxAmt',
      LocalityNm: 'W2LocalTaxGrp LocalityNm',
      WithholdingAmt: 'WithholdingAmt',
    }

    attr_reader :node
    attr_accessor :id
    attr_accessor *SELECTORS.keys
    attr_accessor :_destroy

    def selectors
      SELECTORS
    end

    def initialize(node = nil)
      @node = if node
                node
              else
                Nokogiri::XML(IrsApiService.df_return_sample).at('IRSW2')
              end
    end

    def id
      @node['documentId']
    end

    def EmployeeSSN
      df_xml_value(__method__)
    end

    def EmployeeSSN=(value)
      write_df_xml_value(__method__, value)
    end

    def EmployerEIN
      df_xml_value(__method__)
    end

    def EmployerEIN=(value)
      write_df_xml_value(__method__, value)
    end

    def EmployerName
      df_xml_value(__method__)
    end

    def EmployerName=(value)
      write_df_xml_value(__method__, value)
    end

    def AddressLine1Txt
      df_xml_value(__method__)
    end

    def AddressLine1Txt=(value)
      write_df_xml_value(__method__, value)
    end

    def City
      df_xml_value(__method__)
    end

    def City=(value)
      write_df_xml_value(__method__, value)
    end

    def State
      df_xml_value(__method__)
    end

    def State=(value)
      write_df_xml_value(__method__, value)
    end

    def ZIP
      df_xml_value(__method__)
    end

    def ZIP=(value)
      write_df_xml_value(__method__, value)
    end

    def WagesAmt
      df_xml_value(__method__)&.to_i || 0
    end

    def WagesAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def RetirementPlanInd
      df_xml_value(__method__)
    end

    def ThirdPartySickPayInd
      df_xml_value(__method__)
    end

    def w2_box12
      @node.css('EmployersUseGrp').map do |node|
        {
          code: node.at('EmployersUseCd')&.text,
          value: node.at('EmployersUseAmt')&.text
        }
      end
    end

    def w2_box14
      @node.css('OtherDeductionsBenefitsGrp').map do |node|
        {
          other_description: node.at('Desc')&.text,
          other_amount: node.at('Amt')&.text
        }
      end
    end

    def AllocatedTipsAmt
      df_xml_value(__method__).to_i
    end

    def AllocatedTipsAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def DependentCareBenefitsAmt
      df_xml_value(__method__).to_i
    end

    def DependentCareBenefitsAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def NonqualifiedPlansAmt
      df_xml_value(__method__).to_i
    end

    def NonqualifiedPlansAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def WithholdingAmt
      df_xml_value(__method__)&.to_i || 0
    end

    def WithholdingAmt=(value)
      write_df_xml_value(__method__, value)
    end

    def StateWagesAmt
      df_xml_value(__method__)&.to_i || 0
    end

    def StateWagesAmt=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value)
    end

    def StateIncomeTaxAmt
      df_xml_value(__method__)&.to_i || 0
    end

    def StateIncomeTaxAmt=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value)
    end

    def LocalWagesAndTipsAmt
      df_xml_value(__method__)&.to_i || 0
    end

    def LocalWagesAndTipsAmt=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value) if value.present?
    end

    def LocalIncomeTaxAmt
      df_xml_value(__method__)&.to_i || 0
    end

    def LocalIncomeTaxAmt=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value) if value.present?
    end

    def LocalityNm
      df_xml_value(__method__)
    end

    def LocalityNm=(value)
      create_or_destroy_df_xml_node(__method__, value)
      write_df_xml_value(__method__, value) if value.present?
    end

    def persisted?
      true
    end

    def errors
      ActiveModel::Errors.new(nil)
    end
  end

  class Dependent
    attr_accessor :first_name,
                  :last_name,
                  :ssn,
                  :relationship,
                  :eic_student,
                  :eic_disability,
                  :eic_qualifying,
                  :ctc_qualifying,
                  :odc_qualifying,
                  :months_in_home

    def initialize(first_name:, last_name:, ssn:, relationship:,
                   eic_student: nil, eic_disability: nil, eic_qualifying: nil,
                   ctc_qualifying: nil, odc_qualifying: nil, months_in_home: nil)

      @first_name = first_name
      @last_name = last_name
      @ssn = ssn
      @relationship = relationship
      @eic_student = eic_student
      @eic_disability = eic_disability
      @eic_qualifying = eic_qualifying
      @ctc_qualifying = ctc_qualifying
      @odc_qualifying = odc_qualifying
      @months_in_home = months_in_home
    end

    def attributes
      {
        first_name: @first_name,
        last_name: @last_name,
        ssn: @ssn,
        relationship: @relationship,
        eic_student: @eic_student,
        eic_disability: @eic_disability,
        eic_qualifying: @eic_qualifying,
        ctc_qualifying: @ctc_qualifying,
        odc_qualifying: @odc_qualifying,
        months_in_home: @months_in_home
      }
    end
  end

  def attributes
    [
      :tax_return_year,
      :filing_status,
      :primary_ssn,
      :primary_occupation,
      :spouse_ssn,
      :spouse_occupation,
      :mailing_city,
      :mailing_street,
      :mailing_apartment,
      :mailing_zip,
      :cell_phone_number,
      :tax_payer_email,
      :total_state_tax_withheld,
      :fed_tax,
      :fed_agi,
      :fed_wages,
      :fed_wages_salaries_tips,
      :fed_taxable_income,
      :fed_total_adjustments,
      :fed_taxable_ssb,
      :fed_ssb,
      :fed_eic,
      :fed_ctc,
      :fed_qualify_child,
      :fed_puerto_rico_income_exclusion_amount,
      :total_exempt_primary_spouse,
      :fed_irs_1040_nr,
      :fed_unemployment,
      :fed_housing_deduction_amount,
      :fed_gross_income_exclusion_amount,
      :fed_total_income_exclusion_amount,
      :fed_foreign_tax_credit_amount,
      :fed_credit_for_child_and_dependent_care_amount,
      :fed_education_credit_amount,
      :fed_retirement_savings_contribution_credit_amount,
      :fed_energy_efficiency_home_improvement_credit_amount,
      :fed_credit_for_elderly_or_disabled_amount,
      :fed_clean_vehicle_personal_use_credit_amount,
      :fed_total_reporting_year_tax_increase_or_decrease_amount,
      :fed_previous_owned_clean_vehicle_credit_amount,
      :fed_calculated_difference_amount,
      :fed_nontaxable_combat_pay_amount,
      :fed_total_earned_income_amount,
      :fed_residential_clean_energy_credit_amount,
      :fed_mortgage_interest_credit_amount,
      :fed_adoption_credit_amount,
      :fed_dc_homebuyer_credit_amount,
      :fed_adjustments_claimed
    ].each_with_object({}) do |field, hsh|
      hsh[field] = send(field)
    end
  end

  def can_override?(attribute)
    return false if Rails.env.production?

    respond_to?("#{attribute}=")
  end
end