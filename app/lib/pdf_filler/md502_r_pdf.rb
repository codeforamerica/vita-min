module PdfFiller
  class Md502RPdf
    include PdfHelper

    def source_pdf_name
      "md502R-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'Your First Name': @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'Primary MI': @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        'Your Last Name': @xml_document.at('Primary TaxpayerName LastName')&.text,
        'Your Social Security Number': @xml_document.at('Primary TaxpayerSSN')&.text,
        'Spouses First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Spouse MI': @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text,
        'Spouses Last Name': @xml_document.at('Secondary TaxpayerName LastName')&.text,
        'Spouses Social Security Number': @xml_document.at('Secondary TaxpayerSSN')&.text,
        'Your Age 1': @xml_document.at('PrimaryAge')&.text,
        'Spouses Age': @xml_document.at('SecondaryAge')&.text,
        'and Tier II See Instructions for Part 5                                   9a': @xml_document.at('PriSSecurityRailRoadBenefits')&.text,
        '9b': @xml_document.at('SecSSecurityRailRoadBenefits')&.text,
      }
    end
  end
end
