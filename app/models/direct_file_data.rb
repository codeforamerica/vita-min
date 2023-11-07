class DirectFileData
  def initialize(raw_xml)
    @raw_xml = raw_xml
  end

  def parsed_xml
    @parsed_xml ||= Nokogiri::XML(@raw_xml)
  end

  def to_s
    parsed_xml.to_s
  end

  def tax_return_year
    parsed_xml.at('TaxYr')&.text&.to_i
  end

  def filing_status
    parsed_xml.at('IndividualReturnFilingStatusCd')&.text&.to_i
  end

  def filing_status=(value)
    parsed_xml.at('IndividualReturnFilingStatusCd').content = value
  end

  def phone_daytime
    # TODO
  end

  def phone_daytime_area_code
    # TODO
  end

  # TODO: primary_first_name, primary_last_name and primary_middle_initial need to come over from DF 

  def primary_ssn
    parsed_xml.at('Filer PrimarySSN')&.text
  end

  def primary_ssn=(value)
    parsed_xml.at('Filer PrimarySSN').content = value
  end

  def primary_occupation
    parsed_xml.at('PrimaryOccupationTxt')&.text
  end

  def primary_occupation=(value)
    parsed_xml.at('PrimaryOccupationTxt').content = value
  end

  # TODO: spouse_first_name, spouse_last_name and spouse_middle_initial need to come over from DF

  def spouse_ssn
    parsed_xml.at('Filer SpouseSSN')&.text
  end

  def spouse_ssn=(value)
    unless parsed_xml.at('Filer SpouseSSN').present? && value.present?
      parsed_xml.at('Filer').add_child('<SpouseSSN/>')
    end

    if parsed_xml.at('Filer SpouseSSN')
      parsed_xml.at('Filer SpouseSSN').content = value
    end
  end

  def spouse_occupation
    parsed_xml.at('SpouseOccupationTxt')&.text
  end

  def spouse_occupation=(value)
    unless parsed_xml.at('IRS1040 SpouseOccupationTxt').present? && value.present?
      parsed_xml.at('IRS1040').add_child('<SpouseOccupationTxt/>')
    end

    if parsed_xml.at('SpouseOccupationTxt')
      parsed_xml.at('SpouseOccupationTxt').content = value
    end
  end

  def mailing_city
    parsed_xml.at('USAddress CityNm')&.text
  end

  def mailing_city=(value)
    parsed_xml.at('USAddress CityNm').content = value
  end

  def mailing_street
    parsed_xml.at('USAddress AddressLine1Txt')&.text
  end

  def mailing_street=(value)
    parsed_xml.at('USAddress AddressLine1Txt').content = value
  end

  def mailing_apartment
    # TODO
  end

  def mailing_state
    parsed_xml.at('USAddress StateAbbreviationCd')&.text
  end

  def mailing_state=(value)
    parsed_xml.at('USAddress StateAbbreviationCd').content = value
  end

  def mailing_zip
    parsed_xml.at('USAddress ZIPCd')&.text
  end

  def mailing_zip=(value)
    parsed_xml.at('USAddress ZIPCd').content = value
  end

  def fed_tax
    parsed_xml.at('TotalTaxBeforeCrAndOthTaxesAmt')&.text&.to_i
  end

  def fed_agi
    parsed_xml.at('ReturnData AdjustedGrossIncomeAmt')&.text&.to_i
  end

  def fed_agi=(value)
    parsed_xml.at('ReturnData AdjustedGrossIncomeAmt').content = value
  end

  def fed_wages
    parsed_xml.at('WagesAmt')&.text&.to_i
  end

  def fed_wages=(value)
    parsed_xml.at('WagesAmt').content = value
  end

  def fed_wages_salaries_tips
    parsed_xml.at('WagesSalariesAndTipsAmt')&.text&.to_i
  end

  def fed_taxable_income
    parsed_xml.at('TaxableInterestAmt')&.text&.to_i
  end

  def fed_taxable_income=(value)
    parsed_xml.at('TaxableInterestAmt').content = value
  end

  def fed_unemployment
    parsed_xml.at('IRS1040Schedule1 UnemploymentCompAmt')&.text&.to_i
  end

  def fed_unemployment=(value)
    parsed_xml.at('IRS1040Schedule1 UnemploymentCompAmt').content = value
  end

  def fed_taxable_ssb
    parsed_xml.at('TaxableSocSecAmt')&.text&.to_i
  end

  def fed_taxable_ssb=(value)
    parsed_xml.at('TaxableSocSecAmt').content = value
  end

  def fed_ssb
    parsed_xml.at('SocSecBnftAmt')&.text&.to_i
  end

  def fed_ssb=(value)
    parsed_xml.at('SocSecBnftAmt').content = value
  end

  def fed_non_taxable_ssb
    fed_ssb - fed_taxable_ssb
  end

  def total_fed_adjustments_identify
    "wrenches" # TODO
  end

  def total_fed_adjustments
    0 # TODO
  end

  def total_state_tax_withheld
    0 # TODO
  end

  def fed_eic_claimed
    (parsed_xml.at('EarnedIncomeCreditAmt')&.text&.to_i || 0).positive?
  end

  def fed_eic
    parsed_xml.at('EarnedIncomeCreditAmt')&.text&.to_i
  end

  def fed_eic_qc_claimed
    parsed_xml.at('IRS1040ScheduleEIC QualifyingChildInformation') != nil
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
      :phone_daytime,
      :phone_daytime_area_code,
      :primary_ssn,
      :primary_occupation,
      :spouse_ssn,
      :spouse_occupation,
      :mailing_city,
      :mailing_street,
      :mailing_apartment,
      :mailing_zip,
      :fed_wages,
      :fed_taxable_income,
      :fed_unemployment,
      :fed_taxable_ssb,
      :total_fed_adjustments_identify,
      :total_fed_adjustments,
      :total_state_tax_withheld
    ].each_with_object({}) do |field, hsh|
      hsh[field] = send(field)
    end
  end
end