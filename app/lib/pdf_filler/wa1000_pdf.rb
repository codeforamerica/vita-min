module PdfFiller
  class Wa1000Pdf
    include PdfHelper

    # TODO: add pdf to info service?
    def source_pdf_name
      "az140-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      # TODO: stop hardcoding state abbrev?
      builder = StateFile::StateInformationService.submission_builder_class(:wa)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "1a" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text].join(' '),
        "1b" => [@xml_document.at('Primary TaxpayerName LastName')&.text, @xml_document.at('Primary TaxpayerName NameSuffix')&.text].join(' '),
        "1c" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "2a" => @xml_document.at("USAddress AddressLine1Txt")&.text,
        "2c" => @xml_document.at("USPhone")&.text,
        "City, Town, Post Office" => @xml_document.at("CityNm")&.text,
        "State" => @xml_document.at("StateAbbreviationCd")&.text,
        "ZIP Code" => @xml_document.at("ZIPCd")&.text,
        "Filing Status" => filing_status,
      }

      answers.merge!({
        "79" => @xml_document.at('RefundAmt')&.text,
        "80" => @xml_document.at('AmtOwed')&.text
      })

      direct_file_data = @submission.data_source.direct_file_data
      answers.merge!({
        "81" => direct_file_data.primary_occupation,
        "82" => direct_file_data.spouse_occupation,
      })

      answers
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
    
    FILING_STATUS_OPTIONS = {
      "MarriedJoint" => 'Choice1',
      "HeadHousehold" => 'Choice2', # Qualifying Widow based state_file_az_intake#filing_status
      "MarriedFilingSeparateReturn" => 'Choice3',
      "Single" => 'Choice4',
    }

    def filing_status
      FILING_STATUS_OPTIONS[@xml_document.at('FilingStatus')&.text]
    end
  end
end
