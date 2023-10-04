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

  def primary_dob
    raw_date = parsed_xml.at('SelfSelectPINGrp PrimaryBirthDt')&.text
    Date.parse(raw_date) if raw_date.present?
  end

  def primary_dob=(date)
    parsed_xml.at('SelfSelectPINGrp PrimaryBirthDt').content = date&.strftime("%Y-%m-%d")
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

  def spouse_dob
    raw_date = parsed_xml.at('SelfSelectPINGrp SpouseBirthDt')&.text
    Date.parse(raw_date) if raw_date.present?
  end

  def spouse_dob=(date)
    if date && !parsed_xml.at('SelfSelectPINGrp SpouseBirthDt')
      parsed_xml.at('SelfSelectPINGrp').add_child('<SpouseBirthDt/>')
    end
    if parsed_xml.at('SelfSelectPINGrp SpouseBirthDt')
      parsed_xml.at('SelfSelectPINGrp SpouseBirthDt').content = date&.strftime("%Y-%m-%d")
    end
  end

  def spouse_ssn
    parsed_xml.at('Filer PrimarySSN')&.text
  end

  def spouse_ssn=(value)
    parsed_xml.at('Filer PrimarySSN').content = value
  end

  def spouse_occupation
    parsed_xml.at('SpouseOccupationTxt')&.text
  end

  def spouse_occupation=(value)
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

  def fed_wages
    parsed_xml.at('WagesAmt')&.text&.to_i
  end

  def fed_wages=(value)
    parsed_xml.at('WagesAmt').content = value
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

  def fed_eic_qc_claimed
    parsed_xml.at('IRS1040ScheduleEIC QualifyingChildInformation') != nil
  end

  def attributes
    [
      :tax_return_year,
      :filing_status,
      :phone_daytime,
      :phone_daytime_area_code,
      :primary_dob,
      :primary_ssn,
      :primary_occupation,
      :spouse_dob,
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