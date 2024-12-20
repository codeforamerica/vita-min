module PdfFiller
  class Md502Pdf
    include PdfHelper

    def source_pdf_name
      "md502-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        '1': @xml_document.at("Form502 Income FederalAdjustedGrossIncome")&.text,
        '1a': @xml_document.at("Form502 Income WagesSalariesAndTips")&.text,
        '1b': @xml_document.at("Form502 Income EarnedIncome")&.text,
        '1d': @xml_document.at("Form502 Income TaxablePensionsIRAsAnnuities")&.text,
        'Place a Y in this box if the amount of your investment income is more than 11600': @xml_document.at("Form502 Income InvestmentIncomeIndicator")&.text == "X" ? "Y" : "",
        'Your Social Security Number': @xml_document.at('Primary TaxpayerSSN')&.text,
        'Spouses Social Security Number': @xml_document.at('Secondary TaxpayerSSN')&.text,
        'Your First Name': @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'Primary MI': @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        'Your Last Name': @xml_document.at('Primary TaxpayerName LastName')&.text,
        'Spouses First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Spouse MI': @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text,
        'Spouses Last Name': @xml_document.at('Secondary TaxpayerName LastName')&.text,

        'Current Mailing Address Line 1 Street No and Street Name or PO Box': @xml_document.at('USAddress AddressLine1Txt')&.text,
        'Current Mailing Address Line 2 Apt No Suite No Floor No': @xml_document.at('USAddress AddressLine2Txt')&.text,
        'City or Town': @xml_document.at('USAddress CityNm')&.text,
        'Mailing Address State': @xml_document.at('USAddress StateAbbreviationCd')&.text,
        'ZIP Code  4': @xml_document.at('USAddress ZIPCd')&.text,

        'Maryland Physical Address Line 1 Street No and Street Name No PO Box': @xml_document.at('MarylandAddress AddressLine1Txt')&.text,
        'Maryland Physical Address Line 2 Apt No Suite No Floor No No PO Box': @xml_document.at('MarylandAddress AddressLine2Txt')&.text,
        'City': @xml_document.at('MarylandAddress CityNm')&.text,
        'ZIP Code  4_2': @xml_document.at('MarylandAddress ZIPCd')&.text,

        '4 Digit Political Subdivision Code See Instruction 6': @xml_document.at('MarylandSubdivisionCode')&.text,
        'Maryland Political Subdivision See Instruction 6': @submission.data_source.political_subdivision,
        'Maryland County': @submission.data_source.residence_county,

        'Single If you can be claimed on another persons tax return use Filing Status 6': checkbox_value(filing_status(:filing_status_single?)),
        'Married filing joint return or spouse had no income': checkbox_value(filing_status(:filing_status_mfj?)),
        'Married filing separately Spouse SSN': checkbox_value(filing_status(:filing_status_mfs?)),
        'mfs spouse ssn': spouse_ssn_if_mfs,
        'Head of household': checkbox_value(filing_status(:filing_status_hoh?)),
        'Qualifying surviving spouse with dependent child': checkbox_value(filing_status(:filing_status_qw?)),
        'Dependent taxpayer': checkbox_value(claimed_as_dependent?),
        'A': checkbox_value(@xml_document.at('Exemptions Primary Standard')&.text),
        'Yourself': checkbox_value(@xml_document.at('Exemptions Spouse Standard')&.text),
        'Spouse      Enter number checked': @xml_document.at('Exemptions Standard Count')&.text,
        'A_2': @xml_document.at('Exemptions Standard Amount')&.text,
        'B': checkbox_value(@xml_document.at('Exemptions Primary Over65')&.text),
        '65 or over': checkbox_value(@xml_document.at('Exemptions Spouse Over65')&.text),
        'Primary Blind': checkbox_value(@xml_document.at('Exemptions Primary Blind')&.text),
        'Spouse Blind': checkbox_value(@xml_document.at('Exemptions Spouse Blind')&.text),
        'Blind        Enter number checked': @xml_document.at('Exemptions Additional Count')&.text,
        'X  1000         B': @xml_document.at('Exemptions Additional Amount')&.text,
        'C Enter number from line 3 of Dependent Form 502B': @xml_document.at('Exemptions Dependents Count')&.text,
        'C': @xml_document.at('Exemptions Dependents Amount')&.text,
        'D Enter Total Exemptions Add A B and C': @xml_document.at('Exemptions Total Count')&.text,
        'Total Amount D': @xml_document.at('Exemptions Total Amount')&.text,
        'Check here': check_box_if_x(@xml_document.at('MDHealthCareCoverage PriWithoutHealthCoverageInd')&.text),
        'Check here_2': check_box_if_x(@xml_document.at('MDHealthCareCoverage SecWithoutHealthCoverageInd')&.text),
        'DOB  mmddyyyy': formatted_date(@xml_document.at('MDHealthCareCoverage PriDOB')&.text, "%m/%d/%Y"),
        'DOB  mmddyyyy_2': formatted_date(@xml_document.at('MDHealthCareCoverage SecDOB')&.text, "%m/%d/%Y"),
        'Check here_3': check_box_if_x(@xml_document.at('MDHealthCareCoverage AuthorToShareInfoHealthExchInd')&.text),
        'Email address': @xml_document.at('MDHealthCareCoverage TaxpayerEmailAddress')&.text,
        '9': @xml_document.at('Form502 Subtractions ChildAndDependentCareExpenses')&.text,
        '11': @xml_document.at('Form502 Subtractions SocialSecurityRailRoadBenefits')&.text,
        '1SU': generate_codes_for_502_su.at(0),
        '2SU': generate_codes_for_502_su.at(1),
        '3SU': generate_codes_for_502_su.at(2),
        '4SU': generate_codes_for_502_su.at(3),
        '13': @xml_document.at('Form502 Subtractions Other')&.text,
        '14': @xml_document.at('Form502 Subtractions TwoIncome')&.text,
        '40': @xml_document.at('Form502 TaxWithheld')&.text,
        '40 decimal': @xml_document.at('Form502 TaxWithheld')&.text.present? ? "00" : nil,
        '22': @xml_document.at('Form502 StateTaxComputation EarnedIncomeCredit')&.text,
        'Poverty level credit See Instruction 18': checkbox_value(@xml_document.at('Form502 StateTaxComputation MDEICWithQualChildInd')&.text),
        'Daytime telephone no': @xml_document.at('ReturnHeaderState Filer Primary USPhone')&.text,
        'STANDARD DEDUCTION METHOD': checkbox_value(deduction_method_is_standard?),
        '17': deduction_method_is_standard? ? @xml_document.at('Form502 Deduction Amount')&.text : nil,
        '18': deduction_method_is_standard? ? @xml_document.at('Form502 NetIncome')&.text : nil,
        '19': @xml_document.at('Form502 ExemptionAmount')&.text,
        '20': deduction_method_is_standard? ? @xml_document.at('Form502 StateTaxComputation TaxableNetIncome')&.text : nil,
        '3': @xml_document.at('Form502 Additions StateRetirementPickup')&.text,
        '6_2': @xml_document.at('Form502 Additions Total')&.text,
        '7': @xml_document.at('Form502 Additions FedAGIAndStateAdditions')&.text,
        '15': @xml_document.at('Form502 Subtractions Total')&.text,
        '16': @xml_document.at('Form502 Subtractions StateAdjustedGrossIncome')&.text,
        '21': @xml_document.at('Form502 StateTaxComputation StateIncomeTax')&.text,
        '23': @xml_document.at('Form502 StateTaxComputation PovertyLevelCredit')&.text,
        '24': @xml_document.at('Form502 StateTaxComputation IndividualTaxCredits')&.text,
        '26': @xml_document.at('Form502 StateTaxComputation TotalCredits')&.text,
        '27': @xml_document.at('Form502 StateTaxComputation StateTaxAfterCredits')&.text,
        '43': @xml_document.at('Form502 RefundableTaxCredits')&.text,
        '43 decimal': @xml_document.at('Form502 RefundableTaxCredits')&.text.present? ? "00" : nil,
        '39': calculated_fields.fetch(:MD502_LINE_39),
        '42': calculated_fields.fetch(:MD502_LINE_42),
        '42 decimal': "00",
        '44': calculated_fields.fetch(:MD502_LINE_44),
        '44 decimal': "00",
        '45': calculated_fields.fetch(:MD502_LINE_45),
        '45 decimal': calculated_fields.fetch(:MD502_LINE_45).present? ? "00" : nil,
        '46': calculated_fields.fetch(:MD502_LINE_46),
        '46 decimal': calculated_fields.fetch(:MD502_LINE_46).present? ? "00" : nil,
        '48': calculated_fields.fetch(:MD502_LINE_48),
        '48 decimal': "00",
        '50': calculated_fields.fetch(:MD502_LINE_50),
        '50 decimal': "00",
        'your local tax rate 0': @xml_document.at('Form502 LocalTaxComputation LocalTaxRate')&.text&.split('0.0')&.last,
        '28': @xml_document.at('Form502 LocalTaxComputation LocalIncomeTax')&.text,
        '29': @xml_document.at('Form502 LocalTaxComputation EarnedIncomeCredit')&.text,
        '30': @xml_document.at('Form502 LocalTaxComputation PovertyLevelCredit')&.text,
        '32': @xml_document.at('Form502 LocalTaxComputation TotalCredits')&.text,
        '33': @xml_document.at('Form502 LocalTaxComputation LocalTaxAfterCredits')&.text,
        '34': @xml_document.at('Form502 TotalStateAndLocalTax')&.text,
        'Check here if you authorize the State of Maryland to issue your refund by direct deposit': check_box_if_x(@xml_document.at('Form502 AuthToDirectDepositInd')&.text),
        '51d Names as it appears on the bank account': full_names_of_bank_account_holders || ""
      }
      if @xml_document.at('RefundDirectDeposit').present?
        answers.merge!({
                         'Checking': check_box_if_x(@xml_document.at('Checking')&.text),
                         'Savings': check_box_if_x(@xml_document.at('Savings')&.text),
                         '51b Routing Number 9digits': @xml_document.at('RoutingTransitNumber')&.text,
                         '51c  Account Number': @xml_document.at('BankAccountNumber')&.text,
                       })
      end
      answers
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
      value.present? ? 'On' : 'Off'
    end

    def check_box_if_x(value)
      value == "X" ? 'On' : 'Off'
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

    def full_names_of_bank_account_holders
      intake = @submission.data_source
      return nil unless intake.payment_or_deposit_type.to_sym == :direct_deposit

      if intake.has_joint_account_holder_yes?
        account_holder_full_name + " and " + account_holder_full_name(for_joint: true)
      else
        account_holder_full_name
      end
    end

    def account_holder_full_name(for_joint: false)
      attributes = %w[FirstName MiddleInitial LastName NameSuffix]
      account_holder_xmls = @xml_document.css('Form502 NameOnBankAccount')
      account_holder_xml = for_joint ? account_holder_xmls[1] : account_holder_xmls[0]
      attributes.map { |attr| account_holder_xml.at(attr)&.text }.filter_map(&:presence).join(" ")
    end

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
