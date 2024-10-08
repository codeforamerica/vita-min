module PdfFiller
  class Id40Pdf
    include PdfHelper

    def source_pdf_name
      "idform40-TY-2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nc)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'YearBeginning' => formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodBeginDt')&.text, "%m-%d"),
        'YearEnding' => formatted_date(@xml_document.at('ReturnHeaderState TaxPeriodEndDt')&.text, "%m-%d-%y"),
        'FirstNameInitial' => @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'LastName' => @xml_document.at('Primary TaxpayerName LastName')&.text,
        'SSN' => @xml_document.at('Primary TaxpayerSSN')&.text,
        'SpouseFirstNameInitial' => @xml_document.at('Primary TaxpayerSpouseFirstName')&.text,
        'SpouseLastName' => @xml_document.at('Primary TaxpayerSpouseLastName')&.text,
        'SpouseSSN' => @xml_document.at('Primary TaxpayerSpouseSSN')&.text,
        'CurrentMailing' => [@xml_document.at('Filer USAddress AddressLine1Txt')&.text, @xml_document.at('Filer USAddress AddressLine2Txt')&.text].compact.join(', '),
        'City' => @xml_document.at('Filer USAddress CityNm')&.text,
        'StateAbbrv' => @xml_document.at('Filer USAddress StateAbbreviationCd')&.text,
        'ZIPcode' => @xml_document.at('Filer USAddress ZIPCd')&.text,
        'FilingStatusMarriedJoint' => @submission.data_source.filing_status_mfj? ? 'Yes' : 'Off',
        'FilingStatusSingle' => @submission.data_source.filing_status_single? ? 'Yes' : 'Off',
        'FilingStatusMarriedSeperate' => @submission.data_source.filing_status_mfs? ? 'Yes' : 'Off',
        'FilingStatusHead' => @submission.data_source.filing_status_hoh? ? 'Yes' : 'Off',
        'SpouseDeceased' => @submission.data_source.filing_status_qw? ? 'Yes' : 'Off',
        '6aYourself' => @submission.data_source.direct_file_data.claimed_as_dependent? ? "" : "1",
        '6bSpouse' => @submission.data_source.filing_status_mfj? ? "1" : "",
        '6cDependents' => @submission.data_source.dependents.count,
        '6dTotalHousehold' => dependent_count,
      }
    end

    def dependent_count
      if @submission.data_source.direct_file_data.claimed_as_dependent?
        0
      else
        count = @submission.data_source.dependents.count + 1 # adding yourself as a dependent
        count += 1 if @submission.data_source.filing_status_mfj?
        count
      end
    end

    def formatted_date(date_str, format)
      return if date_str.nil?

      Date.parse(date_str)&.strftime(format)
    end
  end
end
