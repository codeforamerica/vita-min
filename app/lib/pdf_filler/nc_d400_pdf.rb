module PdfFiller
  class NcD400Pdf
    include PdfHelper

    def source_pdf_name
      "ncD400-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nc)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        y_d400wf_datebeg: @xml_document.at('ReturnHeaderState TaxPeriodBeginDt')&.text,
        y_d400wf_dateend: @xml_document.at('ReturnHeaderState TaxPeriodEndDt')&.text,
        y_d400wf_fname1: @xml_document.at('Primary TaxpayerName FirstName')&.text,
        y_d400wf_mi1: @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        y_d400wf_lname1: @xml_document.at('Primary TaxpayerName LastName')&.text,
        y_d400wf_ssn1: @xml_document.at('Primary TaxpayerSSN')&.text,
        y_d400wf_add: @xml_document.at('Filer USAddress AddressLine1Txt')&.text,
        'y_d400wf_apartment number': @xml_document.at('Filer USAddress AddressLine2Txt')&.text,
        y_d400wf_city: @xml_document.at('Filer USAddress CityNm')&.text,
        y_d400wf_state: @xml_document.at('Filer USAddress StateAbbreviationCd')&.text,
        y_d400wf_zip: @xml_document.at('Filer USAddress ZIPCd')&.text
      }
    end

    private

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
