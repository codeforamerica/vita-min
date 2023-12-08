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
    mailing_state: 'ReturnHeader Filer USAddress StateAbbreviationCd',
    mailing_zip: 'ReturnHeader Filer USAddress ZIPCd',
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
    fed_ctc: 'IRS1040 AdditionalChildTaxCreditAmt',
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
    fed_residential_clean_energy_credit_amount: 'IRS5695 ResidentialCleanEnergyCrAmt',
    fed_mortgage_interest_credit_amount: 'IRS8396 MortgageInterestCreditAmt',
    fed_adoption_credit_amount: 'IRS8839 AdoptionCreditAmt',
    fed_dc_homebuyer_credit_amount: 'IRS8859 DCHmByrCurrentYearCreditAmt',
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
    # TODO
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
    df_xml_value(__method__)&.to_i
  end

  def fed_tax=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_agi
    df_xml_value(__method__)&.to_i
  end

  def fed_agi=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_wages
    df_xml_value(__method__)&.to_i
  end

  def fed_wages=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_wages_salaries_tips
    df_xml_value(__method__)&.to_i
  end

  def fed_taxable_income
    df_xml_value(__method__)&.to_i
  end

  def fed_taxable_income=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_unemployment
    df_xml_value(__method__)&.to_i
  end

  def fed_unemployment=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_taxable_ssb
    df_xml_value(__method__)&.to_i
  end

  def fed_taxable_ssb=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_ssb
    df_xml_value(__method__)&.to_i
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
    adjustments.keys.each { |k| adjustments[k][:amount] = df_xml_value(k)&.to_i }
    adjustments.select { |k, info| info[:amount].present? && info[:amount] > 0 }
  end

  def fed_total_adjustments
    df_xml_value(__method__)&.to_i
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
    (fed_ctc || 0).positive?
  end

  def fed_ctc
    df_xml_value(__method__)&.to_i
  end

  def fed_ctc=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_calculated_difference_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_calculated_difference_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_nontaxable_combat_pay_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_nontaxable_combat_pay_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_earned_income_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_total_earned_income_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_puerto_rico_income_exclusion_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_puerto_rico_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_income_exclusion_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_total_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_housing_deduction_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_housing_deduction_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_gross_income_exclusion_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_gross_income_exclusion_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_mortgage_interest_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_mortgage_interest_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_dc_homebuyer_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_dc_homebuyer_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_residential_clean_energy_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_residential_clean_energy_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_adoption_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_adoption_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_foreign_tax_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_foreign_tax_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_credit_for_child_and_dependent_care_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_credit_for_child_and_dependent_care_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_education_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_education_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_retirement_savings_contribution_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_retirement_savings_contribution_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_energy_efficiency_home_improvement_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_energy_efficiency_home_improvement_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_credit_for_elderly_or_disabled_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_credit_for_elderly_or_disabled_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_clean_vehicle_personal_use_credit_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_clean_vehicle_personal_use_credit_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_total_reporting_year_tax_increase_or_decrease_amount
    df_xml_value(__method__)&.to_i
  end

  def fed_total_reporting_year_tax_increase_or_decrease_amount=(value)
    write_df_xml_value(__method__, value)
  end

  def fed_previous_owned_clean_vehicle_credit_amount
    df_xml_value(__method__)&.to_i
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
    df_xml_value(__method__)&.to_i
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
    total_exempt_primary_spouse.zero?
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

  def build_new_qualifying_child_information_node
    dd = parsed_xml.css('QualifyingChildInformation').first
    parsed_xml.css('QualifyingChildInformation').last.add_next_sibling(dd.to_s)
  end

  def w2_nodes
    parsed_xml.css('IRSW2')
  end

  def build_new_w2_node
    w2 = parsed_xml.css('IRSW2').first
    parsed_xml.css('IRSW2').last.add_next_sibling(w2.to_s)
  end

  def dependents
    dependents = parsed_xml.css('DependentDetail').map do |node|
      Dependent.new(
        first_name: node.at('DependentFirstNm')&.text,
        last_name: node.at('DependentLastNm')&.text,
        ssn: node.at('DependentSSN')&.text,
        relationship: node.at('DependentRelationshipCd')&.text,
      )
    end

    parsed_xml.css('IRS1040ScheduleEIC QualifyingChildInformation').map.with_index do |node|
      dependent = dependents.map { |d| d if d.ssn == node.at('QualifyingChildSSN')&.text }.first
      next unless dependent
      if dependent.present?
        dependent.eic_qualifying = true
        dependent.eic_student = node.at('ChildIsAStudentUnder24Ind')&.text
        dependent.eic_disability = node.at('ChildPermanentlyDisabledInd')&.text
        dependent.months_in_home = node.at('MonthsChildLivedWithYouCnt')&.text
      else
        dependents << Dependent.new(
          first_name: node.at('ChildFirstAndLastName PersonFirstNm')&.text,
          last_name: node.at('ChildFirstAndLastName PersonLastNm')&.text,
          ssn: node.at('QualifyingChildSSN')&.text,
          relationship: node.at('ChildRelationshipCd')&.text,
          eic_qualifying: true,
          eic_student: node.at('ChildIsAStudentUnder24Ind')&.text,
          eic_disability: node.at('ChildPermanentlyDisabledInd')&.text,
          months_in_home: node.at('MonthsChildLivedWithYouCnt')&.text,
        )
      end
    end
    dependents
  end

  class Dependent
    attr_accessor :first_name,
                  :last_name,
                  :ssn,
                  :relationship,
                  :eic_student,
                  :eic_disability,
                  :months_in_home,
                  :eic_qualifying

    def initialize(first_name:, last_name:, ssn:, relationship:,
                   eic_student: nil, eic_disability: nil, months_in_home: nil, eic_qualifying: nil)

      @first_name = first_name
      @last_name = last_name
      @ssn = ssn
      @relationship = relationship
      @eic_student = eic_student
      @eic_disability = eic_disability
      @months_in_home = months_in_home
      @eic_qualifying = eic_qualifying
    end

    def attributes
      {
        first_name: @first_name,
        last_name: @last_name,
        ssn: @ssn,
        relationship: @relationship,
        eic_student: @eic_student,
        eic_disability: @eic_disability,
        months_in_home: @months_in_home,
        eic_qualifying: @eic_qualifying,
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