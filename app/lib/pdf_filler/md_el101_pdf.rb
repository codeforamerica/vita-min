module PdfFiller
  class MdEl101Pdf
    include PdfHelper

    def source_pdf_name
      "mdEL101-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      {
        'First Name': @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'Last Name': @xml_document.at('Primary TaxpayerName LastName')&.text,
        'SSNTaxpayer Identification Number': @xml_document.at('Primary TaxpayerSSN')&.text,
        'Spouses First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Spouses Last Name': @xml_document.at('Secondary TaxpayerName LastName')&.text,
        'SSNTaxpayer Identification Number_2': @xml_document.at('Secondary TaxpayerSSN')&.text,
        'Primary signature': [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at  ('Primary TaxpayerName LastName')&.text].join(' '),
        'Primary Date Signed': @xml_document.at('Primary DateSigned')&.text,
        'Spouses signature': [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName LastName')&.text].join(' '),
        'Spouse Date Signed': @xml_document.at('Secondary DateSigned')&.text,
        'Primary Esigned': checkbox_value(@submission.data_source.primary_esigned_yes?),
        'ERO firm name': 'FileYourStateTaxes',
        'ERO firm name 2': @submission.data_source.spouse_esigned_yes? ? 'FileYourStateTaxes' : "",
        'Primary Signature Pin': @xml_document.at('Primary TaxpayerPIN')&.text,
        'Spouse Esigned': checkbox_value(@submission.data_source.spouse_esigned_yes?),
        'Secondary Signature Pin': @xml_document.at('Secondary TaxpayerPIN')&.text
      }
    end

    def checkbox_value(condition)
      condition ? 'On' : 'Off'
    end
  end
end
  