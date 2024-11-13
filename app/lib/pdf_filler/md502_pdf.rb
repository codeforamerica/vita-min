module PdfFiller
  class Md502Pdf
    include PdfHelper

    def source_pdf_name
      "md502-TY2023-with-paren-edit"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'Enter 1': @xml_document.at("Form502 Income FederalAdjustedGrossIncome")&.text,
        'Enter 1a': @xml_document.at("Form502 Income WagesSalariesAndTips")&.text,
        'Enter 1b': @xml_document.at("Form502 Income EarnedIncome")&.text,
        'Enter 1dEnter 1d': @xml_document.at("Form502 Income TaxablePensionsIRAsAnnuities")&.text,
        'Enter Y of income more than $11,000': @xml_document.at("Form502 Income InvestmentIncomeIndicator")&.text == "X" ? "Y" : "",
        'Enter day and month of Fiscal Year beginning': formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodBeginDt')&.text, "%m-%d"),
        'Enter day and month of Fiscal Year Ending': formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodEndDt')&.text, "%m-%d"),
        'Enter social security number': @xml_document.at('Primary TaxpayerSSN')&.text,
        'Enter spouse\'s social security number': @xml_document.at('Secondary TaxpayerSSN')&.text,
        'Enter your first name': @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'Enter your middle initial': @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        'Enter your last name': @xml_document.at('Primary TaxpayerName LastName')&.text,
        'Enter Spouse\'s First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Enter Spouse\'s middle initial': @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text,
        'Enter Spouse\'s last name': @xml_document.at('Secondary TaxpayerName LastName')&.text,

        'Enter Current Mailing Address Line 1 (Street No. and Street Name or PO Box)': @xml_document.at('USAddress AddressLine1Txt')&.text,
        'Enter Current Mailing Address Line 2 (Street No. and Street Name or PO Box)': @xml_document.at('USAddress AddressLine2Txt')&.text,
        'Enter city or town': @xml_document.at('USAddress CityNm')&.text,
        'Enter state': @xml_document.at('USAddress StateAbbreviationCd')&.text,
        'Enter zip code + 4': @xml_document.at('USAddress ZIPCd')&.text,

        'Enter Maryland Physical Address Line 1 (Street No. and Street Name) (No PO Box)': @xml_document.at('MarylandAddress AddressLine1Txt')&.text,
        'Enter Maryland Physical Address Line 2 (Street No. and Street Name) (No PO Box)': @xml_document.at('MarylandAddress AddressLine2Txt')&.text,
        'Enter city': @xml_document.at('MarylandAddress CityNm')&.text,
        '2 Enter zip code + 4': @xml_document.at('MarylandAddress ZIPCd')&.text,

        'Enter 4 Digit Political Subdivision Code (See Instruction 6)': @xml_document.at('MarylandSubdivisionCode')&.text,
        'Enter Maryland Political Subdivision (See Instruction 6)': @submission.data_source.political_subdivision,
        'Enter zip code + 5': @submission.data_source.residence_county,
        'Check Box - 1': filing_status(:filing_status_single?) ? 'Yes' : 'Off',
        'Check Box - 2': filing_status(:filing_status_mfj?) ? 'Yes' : 'Off',
        'Check Box - 3': filing_status(:filing_status_mfs?) ? 'No' : 'Off', # "No" is the checked option
        "MARRIED FILING Enter spouse's social security number": spouse_ssn_if_mfs,
        'Check Box - 4': filing_status(:filing_status_hoh?) ? 'Yes' : 'Off',
        'Check Box - 5': filing_status(:filing_status_qw?) ? 'Yes' : 'Off',
        '6. Check here': claimed_as_dependent? ? 'No' : 'Off', # "No" is the checked option
        'Check Box 15': checkbox_value(@xml_document.at('Exemptions Primary Standard')&.text),
        'Check Box 18': checkbox_value(@xml_document.at('Exemptions Spouse Standard')&.text),
        'Text Field 15': @xml_document.at('Exemptions Standard Count')&.text,
        'Enter A $': @xml_document.at('Exemptions Standard Amount')&.text,
        'Check Box 20': checkbox_value(@xml_document.at('Exemptions Primary Over65')&.text),
        'Check Box 21': checkbox_value(@xml_document.at('Exemptions Spouse Over65')&.text),
        'B. Check this box if you are blind': checkbox_value(@xml_document.at('Exemptions Primary Blind')&.text),
        'B. Check this box if your spouse is blind': checkbox_value(@xml_document.at('Exemptions Spouse Blind')&.text),
        'B. Enter number exemptions checked B': @xml_document.at('Exemptions Additional Count')&.text,
        'Enter B $ ': @xml_document.at('Exemptions Additional Amount')&.text,
        'Text Field 16': @xml_document.at('Exemptions Dependents Count')&.text,
        'Enter C $ ': @xml_document.at('Exemptions Dependents Amount')&.text,
        'Text Field 17': @xml_document.at('Exemptions Total Count')&.text,
        'D. Enter Dollar Amount Total Exemptions (Add A, B and C.) ': @xml_document.at('Exemptions Total Amount')&.text,
        'Enter 9': @xml_document.at('Form502 Subtractions ChildAndDependentCareExpenses')&.text,
        'Enter 11': @xml_document.at('Form502 Subtractions SocialSecurityRailRoadBenefits')&.text,
        'Text Field 9': generate_codes_for_502_su.at(0),
        'Text Field 10': generate_codes_for_502_su.at(1),
        'Text Field 11': generate_codes_for_502_su.at(2),
        'Text Field 12': generate_codes_for_502_su.at(3),
        'Enter 13': @xml_document.at('Form502 Subtractions Other')&.text,
        'Text Box 68': @xml_document.at('Form502 TaxWithheld')&.text,
        'Text Box 34': @xml_document.at('Form502 StateTaxComputation EarnedIncomeCredit')&.text,
        'Check Box 37': checkbox_value(@xml_document.at('Form502 StateTaxComputation MDEICWithQualChildInd')&.text),
        'Text Box 96': @xml_document.at('ReturnHeaderState Filer Primary USPhone')&.text,
        'Check Box 34': deduction_method_is_standard? ? "Yes" : "Off",
        'Enter 17': deduction_method_is_standard? ? @xml_document.at('Form502 Deduction Amount')&.text : nil,
        'Enter 18': deduction_method_is_standard? ? @xml_document.at('Form502 NetIncome')&.text : nil,
        'Enter 19 ': deduction_method_is_standard? ? @xml_document.at('Form502 ExemptionAmount')&.text : nil,
        'Enter 20': deduction_method_is_standard? ? @xml_document.at('Form502 StateTaxComputation TaxableNetIncome')&.text : nil,
        'Enter 3': @xml_document.at('Form502 Additions StateRetirementPickup')&.text,
        'Enter 6': @xml_document.at('Form502 Additions Total')&.text,
        'Enter 7': @xml_document.at('Form502 Additions FedAGIAndStateAdditions')&.text,
        'Text Box 30': @xml_document.at('Form502 StateTaxComputation StateIncomeTax')&.text,
        'Text Box 36': @xml_document.at('Form502 StateTaxComputation PovertyLevelCredit')&.text,
        'Text Box 40': @xml_document.at('Form502 StateTaxComputation TotalCredits')&.text,
        'Text Box 42': @xml_document.at('Form502 StateTaxComputation StateTaxAfterCredits')&.text,
      }
    end

    def spouse_ssn_if_mfs
      filing_status(:filing_status_mfs?) ? @xml_document.at('FilingStatus MarriedFilingSeparately')['spouseSSN'] : nil
    end

    def claimed_as_dependent?
      @submission.data_source.direct_file_data.claimed_as_dependent?
    end

    def deduction_method_is_standard?
      @xml_document.at('Form502 Deduction Method')&.text == "S"
    end

    def filing_status(method)
      claimed_as_dependent? ? false : @submission.data_source.send(method)
    end

    def checkbox_value(value)
      value.present? ? 'Yes' : 'Off'
    end

    def generate_codes_for_502_su
      calculated_fields_code_letters = {
        MD502_SU_LINE_AB: "ab",
        MD502_SU_LINE_U: "u",
        MD502_SU_LINE_V: "v"
      }
      applicable_codes = []

      if calculated_fields.fetch(:MD502_SU_LINE_1).positive?
        calculated_fields_code_letters.each do |calculated_field, code_letter|
          applicable_codes << code_letter if calculated_fields.fetch(calculated_field).to_i.positive?
        end
      end
      applicable_codes
    end

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
