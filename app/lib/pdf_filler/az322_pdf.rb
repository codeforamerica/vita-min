module PdfFiller
  class Az322Pdf
    include PdfHelper

    def source_pdf_name
      "az322-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:az)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      answers = {
        "TP_Name" => [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName MiddleInitial')&.text, @xml_document.at('Primary TaxpayerName LastName')&.text, @xml_document.at('Primary TaxpayerName NameSuffix')&.text].join(' '),
        "TP_SSN" => @xml_document.at('Primary TaxpayerSSN')&.text,
        "Spouse_NAME" => [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text, @xml_document.at('Secondary TaxpayerName LastName')&.text, @xml_document.at('Secondary TaxpayerName NameSuffix')&.text].join(' '),
        "Spouse_SSN" => @xml_document.at('Secondary TaxpayerSSN')&.text,

      }
    end
  end
end
