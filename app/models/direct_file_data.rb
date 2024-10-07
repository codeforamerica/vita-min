class DirectFileData < DfXmlAccessor
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
    fed_tax_amt: 'IRS1040 TotalTaxBeforeCrAndOthTaxesAmt',
    fed_agi: 'IRS1040 AdjustedGrossIncomeAmt',
    fed_wages: 'IRS1040 WagesAmt',
    fed_wages_salaries_tips: 'IRS1040 WagesSalariesAndTipsAmt',
    fed_taxable_income: 'IRS1040 TaxableInterestAmt',
    fed_taxable_pensions: 'IRS1040 TotalTaxablePensionsAmt',
    fed_educator_expenses: 'IRS1040Schedule1 EducatorExpensesAmt',
    fed_student_loan_interest: 'IRS1040Schedule1 StudentLoanInterestDedAmt',
    fed_total_adjustments: 'IRS1040Schedule1 TotalAdjustmentsAmt',
    fed_taxable_ssb: 'IRS1040 TaxableSocSecAmt',
    fed_ssb: 'IRS1040 SocSecBnftAmt',
    fed_eic: 'IRS1040 EarnedIncomeCreditAmt',
    fed_refund_amt: 'IRS1040 RefundAmt',
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
    hoh_qualifying_person_name: 'IRS1040 QualifyingHOHNm',
    surviving_spouse: 'IRS1040 SurvivingSpouseInd',
    third_party_designee_ind: 'IRS1040 ThirdPartyDesigneeInd',
    third_party_designee_name: 'IRS1040 ThirdPartyDesigneeNm',
    third_party_designee_phone_number: 'IRS1040 ThirdPartyDesigneePhoneNum',
    third_party_designee_pin: 'IRS1040 ThirdPartyDesigneePIN',
    spouse_date_of_death: 'IRS1040 SpouseDeathDt',
    spouse_name: 'IRS1040 SpouseNm',
    non_resident_alien: 'IRS1040 NRALiteralCd',
    interest_reported_amount: 'IRS1040 InterestReported', # fake
    primary_blind: 'IRS1040 PrimaryBlindInd',
    spouse_blind: 'IRS1040 SpouseBlindInd',
    qualifying_children_under_age_ssn_count: 'IRS1040Schedule8812 QlfyChildUnderAgeSSNCnt'
  }.freeze

  def initialize(raw_xml)
    @raw_xml = raw_xml
  end

  def self.selectors
    SELECTORS
  end

  define_xml_readers

  def parsed_xml
    @parsed_xml ||= Nokogiri::XML(@raw_xml)
  end

  def node
    parsed_xml
  end

  def to_s
    parsed_xml.to_s
  end

  def tax_return_year=(value)
    write_df_xml_value(__method__, value)
  end

  def filing_status=(value)
    write_df_xml_value(__method__, value)
  end

  def primary_ssn=(value)
    write_df_xml_value(__method__, value)
  end

  def primary_occupation=(value)
    write_df_xml_value(__method__, value)
  end

  def phone_number=(value)
    create_or_destroy_df_xml_node(__method__, value, after="Filer USAddress")
    write_df_xml_value(__method__, value)
  end

  def spouse_ssn=(value)
    create_or_destroy_df_xml_node(__method__, value, after = "PrimarySSN")

    if value.present?
      write_df_xml_value(__method__, value)
    end
  end

  def spouse_occupation=(value)
    create_or_destroy_df_xml_node(__method__, value, after = "PrimaryOccupationTxt")

    if value.present?
      write_df_xml_value(__method__, value)
    end
  end

  def spouse_deceased?
    surviving_spouse == "X"
  end

  def sum_of_1099r_payments_received
    parsed_xml.search("IRS1099R").reduce(0) { |sum, el| sum + el.at("TaxableAmt")&.text.to_i }
  end

  def surviving_spouse=(value)
    if value.present?
      write_df_xml_value(__method__, value)
    end
  end

  def spouse_date_of_death=(value)
    if value.present?
      create_or_destroy_df_xml_node(__method__, value, after = "IndividualReturnFilingStatusCd")
      write_df_xml_value(__method__, value)
    end
  end

  def spouse_name=(value)
    if value.present?
      write_df_xml_value(__method__, value)
    end
  end

  def mailing_city=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_street=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_apartment=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_state=(value)
    write_df_xml_value(__method__, value)
  end

  def mailing_zip=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_tax_amt=(value)
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

  def fed_wages_salaries_tips=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_taxable_income
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_taxable_income=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_taxable_pensions
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_taxable_pensions=(value)
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
    adjustments.each_key { |k| adjustments[k][:amount] = df_xml_value(k)&.to_i || 0 }
    adjustments.select { |_k, info| info[:amount].present? && (info[:amount]).positive? }
  end

  def fed_total_adjustments
    df_xml_value(__method__)&.to_i || 0
  end

  def fed_total_adjustments=(value)
    write_df_xml_value(__method__, value)
  end

  def total_1099r_state_tax_withheld
    form1099rs.sum(&:state_tax_withheld_amount)
  end

  def total_w2_state_tax_withheld
    w2s.sum(&:StateIncomeTaxAmt)
  end

  def total_w2_local_tax_withheld
    w2s.sum(&:LocalIncomeTaxAmt)
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

  def fed_calculated_difference_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_nontaxable_combat_pay_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_earned_income_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_puerto_rico_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_housing_deduction_amount=(value)
    write_df_xml_value(__method__, value)
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

  def fed_refund_amt
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

  def primary_blind
    create_or_destroy_df_xml_node(__method__, true, 'VirtualCurAcquiredDurTYInd')
    write_df_xml_value(__method__, "X")
  end

  def spouse_blind
    create_or_destroy_df_xml_node(__method__, true, 'VirtualCurAcquiredDurTYInd')
    write_df_xml_value(__method__, "X")
  end

  def is_primary_blind?
    parsed_xml.at('PrimaryBlindInd').present?
  end

  def is_spouse_blind?
    parsed_xml.at('SpouseBlindInd').present?
  end

  def blind_primary_spouse
    value = 0
    if is_primary_blind?
      value += 1
    end
    if is_spouse_blind?
      value += 1
    end
    value
  end

  def ny_public_employee_retirement_contributions
    box14_total = 0
    retirement_types = %w[ERSNYSRE NYSERS RET RETSH TIER3RET ERSRETCO NYSRETCO RETDEF RETSM TIER4 ERS NYRET PUBRET RETMT TIER4RET RETSUM]

    parsed_xml.css('IRSW2 OtherDeductionsBenefitsGrp').map do |deduction|
      desc = deduction.at('Desc')&.text
      amt = deduction.at('Amt')&.text.to_i

      if retirement_types.include?(desc.upcase.gsub(/[\s()]/, '')) || desc.upcase.gsub(/[\s()_]/, '')[0..3] == '414H'
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

  def third_party_designee_ind
    df_xml_value(__method__)
  end

  def third_party_designee_ind=(value)
    create_or_destroy_df_xml_node(__method__, true, 'ThirdPartyDesigneeInd')
    write_df_xml_value(__method__, value)
  end

  def third_party_designee_name
    df_xml_value(__method__)
  end

  def third_party_designee_name=(value)
    write_df_xml_value(__method__, value)
  end

  def third_party_designee_phone_number
    df_xml_value(__method__)
  end

  def third_party_designee_phone_number=(value)
    write_df_xml_value(__method__, value)
  end

  def third_party_designee_pin
    df_xml_value(__method__)
  end

  def third_party_designee_pin=(value)
    write_df_xml_value(__method__, value)
  end

  def non_resident_alien
    df_xml_value(__method__)
  end

  def non_resident_alien=(value)
    write_df_xml_value(__method__, value)
  end

  # fake
  def interest_reported_amount
    df_xml_value(__method__)&.to_i || 0
  end

  # fake
  def interest_reported_amount=(value)
    create_or_destroy_df_xml_node(__method__, value)
    write_df_xml_value(__method__, value)
  end

  def qualifying_children_under_age_ssn_count=(value)
    write_df_xml_value(__method__, value)
  end

  def w2_nodes
    parsed_xml.css('IRSW2')
  end

  def w2s
    parsed_xml.css('IRSW2').map do |node|
      DfW2.new(node)
    end
  end

  def form1099r_nodes
    parsed_xml.css('IRS1099R')
  end

  def form1099rs
    parsed_xml.css('IRS1099R').map do |node|
      Df1099R.new(node)
    end
  end

  def build_new_w2_node
    w2 = parsed_xml.css('IRSW2').first
    parsed_xml.css('IRSW2').last.add_next_sibling(w2.to_s)
  end

  def build_new_1099r_node
    form1099r = parsed_xml.css('IRS1099R').first
    parsed_xml.css('IRS1099R').last.add_next_sibling(form1099r.to_s)
  end

  def eitc_eligible_dependents
    @eligible_dependents ||= Hash.new {}
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
    
  class DfW2 < DfW2Accessor
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

  class Df1099R < Df1099rAccessor; end

  def attributes
    %i[
      tax_return_year
      filing_status
      primary_ssn
      primary_occupation
      spouse_ssn
      spouse_occupation
      mailing_city
      mailing_street
      mailing_apartment
      mailing_zip
      cell_phone_number
      phone_number
      tax_payer_email
      total_w2_state_tax_withheld
      fed_tax_amt
      fed_agi
      fed_wages
      fed_wages_salaries_tips
      fed_taxable_income
      fed_total_adjustments
      fed_taxable_ssb
      fed_ssb
      fed_eic
      fed_refund_amt
      fed_ctc
      fed_qualify_child
      fed_puerto_rico_income_exclusion_amount
      total_exempt_primary_spouse
      fed_irs_1040_nr
      fed_unemployment
      fed_housing_deduction_amount
      fed_gross_income_exclusion_amount
      fed_total_income_exclusion_amount
      fed_foreign_tax_credit_amount
      fed_credit_for_child_and_dependent_care_amount
      fed_education_credit_amount
      fed_retirement_savings_contribution_credit_amount
      fed_energy_efficiency_home_improvement_credit_amount
      fed_credit_for_elderly_or_disabled_amount
      fed_clean_vehicle_personal_use_credit_amount
      fed_total_reporting_year_tax_increase_or_decrease_amount
      fed_previous_owned_clean_vehicle_credit_amount
      fed_calculated_difference_amount
      fed_nontaxable_combat_pay_amount
      fed_total_earned_income_amount
      fed_residential_clean_energy_credit_amount
      fed_mortgage_interest_credit_amount
      fed_adoption_credit_amount
      fed_dc_homebuyer_credit_amount
      fed_adjustments_claimed
      fed_taxable_pensions
    ].each_with_object({}) do |field, hsh|
      hsh[field] = send(field)
    end
  end

  def can_override?(attribute)
    return false if Rails.env.production?

    respond_to?("#{attribute}=")
  end
end