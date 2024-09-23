module PdfFiller
  class NcD400ScheduleSPdf
    include PdfHelper

    def source_pdf_name
      "ncD400-Schedule-S-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nc)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        y_d400schswf_ssn: @xml_document.at('Primary TaxpayerSSN')&.text,
        y_d400wf_lname2_PG2: @xml_document.at('Primary TaxpayerName LastName')&.text,
        y_d400schswf_li27_good:  @xml_document.at('DedFedAGI ExmptIncFedRecInd')&.text,
        y_d400schswf_li41_good:  @xml_document.at('DedFedAGI TotDedFromFAGI')&.text,
      }
    end

    def checkbox_value(condition)
      condition ? 'Yes' : 'Off'
    end

    def formatted_date(date_str, format)
      return if date_str.nil?

      Date.parse(date_str)&.strftime(format)
    end
  end
end
