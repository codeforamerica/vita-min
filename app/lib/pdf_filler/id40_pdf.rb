module PdfFiller
  class Id40Pdf
    include PdfHelper
    include SubmissionBuilder::FormattingMethods

    def source_pdf_name
      "idform40-TY-2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:id)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        'YearBeginning' => formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodBeginDt')&.text, "%Y"),
        'YearEnding' => formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodEndDt')&.text, "%Y"),
        'FirstNameInitial' => @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'LastName' => @xml_document.at('Primary TaxpayerName LastName')&.text,
        'SSN' => @xml_document.at('Primary TaxpayerSSN')&.text,
        'SpouseFirstNameInitial' => @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'SpouseLastName' => @xml_document.at('Secondary TaxpayerName LastName')&.text,
        'SpouseSSN' => @xml_document.at('Secondary TaxpayerSSN')&.text,
        'CurrentMailing' => [@xml_document.at('Filer USAddress AddressLine1Txt')&.text, @xml_document.at('Filer USAddress AddressLine2Txt')&.text].compact.join(', '),
        'City' => @xml_document.at('Filer USAddress CityNm')&.text,
        'StateAbbrv' => @xml_document.at('Filer USAddress StateAbbreviationCd')&.text,
        'ZIPcode' => @xml_document.at('Filer USAddress ZIPCd')&.text,
        'FilingStatusMarriedJoint' => @submission.data_source.filing_status_mfj? ? 'Yes' : 'Off',
        'FilingStatusSingle' => @submission.data_source.filing_status_single? ? 'Yes' : 'Off',
        'FilingStatusMarriedSeparate' => @submission.data_source.filing_status_mfs? ? 'Yes' : 'Off',
        'FilingStatusHead' => @submission.data_source.filing_status_hoh? ? 'Yes' : 'Off',
        'SpouseDeceased' => @submission.data_source.filing_status_qw? ? 'Yes' : 'Off',
        '6aYourself' =>  @xml_document.at('PrimeExemption')&.text,
        '6bSpouse' => @xml_document.at('SpouseExemption')&.text,
        '6cDependents' => @xml_document.at('OtherExemption')&.text,
        '6dTotalHousehold' => @xml_document.at('TotalExemption')&.text,
        'OtherTaxesL29' => @xml_document.at('StateUseTax')&.text,
        'OtherTaxesL32Check' => @xml_document.at('PublicAssistanceIndicator')&.text == "true" ? 'Yes' : 'Off',
        'PymntOtherCreditL46' => @xml_document.at('TaxWithheld')&.text,
      }
      @submission.data_source.dependents.first(4).each_with_index do |dependent, index|
        answers.merge!(
          "6cDependent#{index+1}First" => dependent.first_name,
          "6cDependent#{index+1}Last" => dependent.last_name,
          "6cDependent#{index+1}SSN" => dependent.ssn,
          "6cDependent#{index+1}Birthdate" => dependent.dob.strftime('%m/%d/%Y'),
          )
      end
      if @submission.data_source.primary_esigned_yes?
        answers["DateSign 2"] = date_type_for_timezone(@submission.data_source.primary_esigned_at)&.strftime("%m-%d-%Y")
        answers["TaxpayerPhoneNo"] = @submission.data_source.direct_file_data.phone_number
      end
      answers
    end

    def formatted_date(date_str, format)
      return if date_str.nil?

      Date.parse(date_str)&.strftime(format)
    end
  end
end
