module PdfFiller
  class Id40Pdf
    include PdfHelper
    include SubmissionBuilder::FormattingMethods

    def source_pdf_name
      "idform40-TY-2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        'FirstNameInitial' => @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'LastName' => @xml_document.at('Primary TaxpayerName LastName')&.text,
        'SSN' => @xml_document.at('Primary TaxpayerSSN')&.text,
        'SpouseFirstNameInitial' => @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'SpouseLastName' => @xml_document.at('Secondary TaxpayerName LastName')&.text,
        'SpouseSSN' => @xml_document.at('Secondary TaxpayerSSN')&.text,
        'SpouseDeceased 2' => @submission.data_source.spouse_deceased? ? 'Yes' : 'Off',
        'CurrentMailing' => [@xml_document.at('Filer USAddress AddressLine1Txt')&.text, @xml_document.at('Filer USAddress AddressLine2Txt')&.text].compact.join(', '),
        'City' => @xml_document.at('Filer USAddress CityNm')&.text,
        'StateAbbrv' => @xml_document.at('Filer USAddress StateAbbreviationCd')&.text,
        'ZIPcode' => @xml_document.at('Filer USAddress ZIPCd')&.text,
        'FilingStatusMarriedJoint' => @submission.data_source.filing_status_mfj? ? 'Yes' : 'Off',
        'FilingStatusSingle' => @submission.data_source.filing_status_single? ? 'Yes' : 'Off',
        'FilingStatusMarriedSeparate' => @submission.data_source.filing_status_mfs? ? 'Yes' : 'Off',
        'FilingStatusHead' => @submission.data_source.filing_status_hoh? ? 'Yes' : 'Off',
        'SpouseDeceased' => @submission.data_source.filing_status_qw? ? 'Yes' : 'Off',
        '6aYourself' => @xml_document.at('PrimeExemption')&.text,
        '6bSpouse' => @xml_document.at('SpouseExemption')&.text,
        '6cDependents' => @xml_document.at('OtherExemption')&.text,
        '6dTotalHousehold' => @xml_document.at('TotalExemption')&.text,
        'IncomeL7' => @xml_document.at('Form40 FederalAGI')&.text,
        'IncomeL8' => @xml_document.at('Form39R TotalAdditions')&.text,
        'IncomeL9' => @xml_document.at('Form40 FederalAGI')&.text,
        'IncomeL10' => @xml_document.at('Form39R TotalSubtractions')&.text,
        'IncomeL11' => @xml_document.at('Form40 StateTotalAdjustedIncome')&.text,
        'L12aYourself ' => @xml_document.at('PrimeOver65')&.text == "1" ? "Yes" : "Off",
        'L12aSpouse' => @xml_document.at('SpouseOver65')&.text == "1" ? "Yes" : "Off",
        'L12bYourself' => @xml_document.at('PrimeBlind')&.text == "1" ? "Yes" : "Off",
        'L12bSpouse' => @xml_document.at('SpouseBlind')&.text == "1" ? "Yes" : "Off",
        'L12cDependent' => @xml_document.at('ClaimedAsDependent')&.text == "1" ? "Yes" : "Off",
        'TxCompL15' => 0,
        'TxCompL16' => @xml_document.at('StandardDeduction')&.text,
        'TxCompL17' => @xml_document.at('TaxableIncomeState')&.text,
        'TxCompL19' => @xml_document.at('TaxableIncomeState')&.text,
        'TxCompL20' => round_amount_to_nearest_integer(@xml_document.at('StateIncomeTax')&.text),
        'L21' => round_amount_to_nearest_integer(@xml_document.at('StateIncomeTax')&.text),
        'CreditsL23' => @xml_document.at('Form39R TotalSupplementalCredits')&.text,
        'CreditsL25' => @xml_document.at('Form40 IdahoChildTaxCredit')&.text,
        'CreditsL26' => calculated_fields.fetch(:ID40_LINE_26),
        'CreditsL27' => calculated_fields.fetch(:ID40_LINE_27),
        'OtherTaxesL29' => @xml_document.at('StateUseTax')&.text,
        'OtherTaxesL33' => @xml_document.at('TotalTax')&.text,
        'OtherTaxesL32Check' => @xml_document.at('PublicAssistanceIndicator')&.text == "true" ? 'Yes' : 'Off',
        'DonationsL42' => calculated_fields.fetch(:ID40_LINE_42),
        'PymntOtherCreditsL43' => @xml_document.at('WorksheetGroceryCredit')&.text,
        'PymntsOtherCreditsCheck' => @xml_document.at('DonateGroceryCredit')&.text == 'true' ? 'Yes' : 'Off',
        'PymntOtherCreditL43Amount' => @xml_document.at('GroceryCredit')&.text,
        'PymntOtherCreditL46' => @xml_document.at('TaxWithheld')&.text,
        'PymntOtherCreditL50Total' => calculated_fields.fetch(:ID40_LINE_50),
        'TxDueRefundL51' => @xml_document.at('TaxDue')&.text,
        'TxDueRefundL54' => @xml_document.at('TotalDue')&.text,
        'TxDueRefundL55' => @xml_document.at('OverpaymentAfterPenaltyAndInt')&.text,
        'RefundedL56' => @xml_document.at('OverpaymentRefunded')&.text,
      }
      @submission.data_source.dependents.first(4).each_with_index do |dependent, index|
        answers.merge!(
          "6cDependent#{index + 1}First" => dependent.first_name,
          "6cDependent#{index + 1}Last" => dependent.last_name,
          "6cDependent#{index + 1}SSN" => dependent.ssn,
          "6cDependent#{index + 1}Birthdate" => dependent.dob.strftime('%m/%d/%Y'),
        )
      end
      if @submission.data_source.primary_esigned_yes?
        answers["DateSign 2"] = date_type_for_timezone(@submission.data_source.primary_esigned_at)&.strftime("%m-%d-%Y")
        answers["TaxpayerPhoneNo"] = @submission.data_source.direct_file_data.phone_number
      end
      if @xml_document.at('RefundDirectDeposit').present?
        answers.merge!({
                         'DirectDepositL57Route' => @xml_document.at('RoutingTransitNumber')&.text,
                         'DirectDepositL57Acct' => @xml_document.at('BankAccountNumber')&.text,
                         'DirectDepositChecking' => @xml_document.at('Checking')&.text == "X" ? 'Yes' : 'Off',
                         'DirectDepositSavings' => @xml_document.at('Savings')&.text == "X" ? 'Yes' : 'Off',
                       })
      end
      if @xml_document.at('WildlifeDonation').present?
        answers.merge!({ 'DonationsL34' => @xml_document.at('WildlifeDonation')&.text })
      end
      if @xml_document.at('ChildrensTrustDonation').present?
        answers.merge!({ 'DonationsL35' => @xml_document.at('ChildrensTrustDonation')&.text })
      end
      if @xml_document.at('SpecialOlympicDonation').present?
        answers.merge!({ 'DonationsL36' => @xml_document.at('SpecialOlympicDonation')&.text })
      end
      if @xml_document.at('NationalGuardDonation').present?
        answers.merge!({ 'DonationsL37' => @xml_document.at('NationalGuardDonation')&.text })
      end
      if @xml_document.at('RedCrossDonation').present?
        answers.merge!({ 'DonationsL38' => @xml_document.at('RedCrossDonation')&.text })
      end
      if @xml_document.at('VeteransSupportDonation').present?
        answers.merge!({ 'DonationsL39' => @xml_document.at('VeteransSupportDonation')&.text })
      end
      if @xml_document.at('FoodBankDonation').present?
        answers.merge!({ 'DonationsL40' => @xml_document.at('FoodBankDonation')&.text })
      end
      if @xml_document.at('OpportunityScholarshipProgram').present?
        answers.merge!({ 'DonationsL41' => @xml_document.at('OpportunityScholarshipProgram')&.text })
      end
      answers
    end

    def formatted_date(date_str, format)
      return if date_str.nil?

      Date.parse(date_str)&.strftime(format)
    end

    def round_amount_to_nearest_integer(str_value)
      str_value.to_f.round
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
