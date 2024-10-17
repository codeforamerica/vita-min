module PdfFiller
  class Md502Pdf
    include PdfHelper

    def source_pdf_name
      "md502-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        "Enter 1": @xml_document.at("Form502 Income FederalAdjustedGrossIncome")&.text,
        "Enter 1a": @xml_document.at("Form502 Income WagesSalariesAndTips")&.text,
        "Enter 1b": @xml_document.at("Form502 Income EarnedIncome")&.text,
        "Enter 1dEnter 1d": @xml_document.at("Form502 Income TaxablePensionsIRAsAnnuities")&.text,
        "Enter Y of income more than $11,000": @xml_document.at("Form502 Income InvestmentIncomeIndicator")&.text == "X" ? "Y" : "",
        "Enter day and month of Fiscal Year beginning": formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodBeginDt')&.text, "%m-%d"),
        "Enter day and month of Fiscal Year Ending": formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodEndDt')&.text, "%m-%d"),
        "Enter social security number": @xml_document.at('Primary TaxpayerSSN')&.text,
        'Enter spouse\'s social security number': @xml_document.at('Secondary TaxpayerSSN')&.text,
        "Enter your first name": @xml_document.at('Primary TaxpayerName FirstName')&.text,
        "Enter your middle initial": @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        "Enter your last name": @xml_document.at('Primary TaxpayerName LastName')&.text,
        'Enter Spouse\'s First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Enter Spouse\'s middle initial': @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text,
        'Enter Spouse\'s last name': @xml_document.at('Secondary TaxpayerName LastName')&.text,
        "Check Box - 1": filing_status(:filing_status_single?) ? 'Yes' : 'Off',
        "Check Box - 2": filing_status(:filing_status_mfj?) ? 'Yes' : 'Off',
        "Check Box - 3": filing_status(:filing_status_mfs?) ? 'No' : 'Off', # "No" is the checked option
        "MARRIED FILING Enter spouse's social security number": spouse_ssn_if_mfs,
        "Check Box - 4": filing_status(:filing_status_hoh?) ? 'Yes' : 'Off',
        "Check Box - 5": filing_status(:filing_status_qw?) ? 'Yes' : 'Off',
        "6. Check here": claimed_as_dependent? ? 'No' : 'Off', # "No" is the checked option
        "Text Field 16": @xml_document.at('Exemptions Dependents Count')&.text,
        "Enter C $ ": @xml_document.at('Exemptions Dependents Amount')&.text,
        "Enter 9": @xml_document.at('Form502 Subtractions ChildAndDependentCareExpenses')&.text,
        "Enter 11": @xml_document.at('Form502 Subtractions SocialSecurityRailRoadBenefits')&.text,
        "Text Box 96": @xml_document.at('ReturnHeaderState Filer Primary USPhone')&.text,
      }
    end

    def spouse_ssn_if_mfs
      filing_status(:filing_status_mfs?) ? @xml_document.at('FilingStatus MarriedFilingSeparately')['spouseSSN'] : nil
    end

    def claimed_as_dependent?
      @submission.data_source.direct_file_data.claimed_as_dependent?
    end

    def filing_status(method)
      claimed_as_dependent? ? false : @submission.data_source.send(method)
    end
  end
end
