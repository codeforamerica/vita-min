module PdfFiller
  class MdEl101Pdf
    include PdfHelper

    def source_pdf_name
      "mdEL101-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:md)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf

      signature = [@xml_document.at('Primary TaxpayerName FirstName')&.text, @xml_document.at('Primary TaxpayerName LastName')&.text].join(' ')
      spouse_signature = @submission.data_source.spouse_esigned_yes? ? [@xml_document.at('Secondary TaxpayerName FirstName')&.text, @xml_document.at('Secondary TaxpayerName LastName')&.text].join(' ') : ""
      {
        'First Name': @xml_document.at('Primary TaxpayerName FirstName')&.text,
        'Primary MI': @xml_document.at('Primary TaxpayerName MiddleInitial')&.text,
        'Last Name': @xml_document.at('Primary TaxpayerName LastName')&.text,
        'SSNTaxpayer Identification Number': @xml_document.at('Primary TaxpayerSSN')&.text,
        'Spouses First Name': @xml_document.at('Secondary TaxpayerName FirstName')&.text,
        'Spouse MI': @xml_document.at('Secondary TaxpayerName MiddleInitial')&.text,
        'Spouses Last Name': @xml_document.at('Secondary TaxpayerName LastName')&.text,
        'SSNTaxpayer Identification Number_2': @xml_document.at('Secondary TaxpayerSSN')&.text,
        '2 Amount of overpayment to be refunded to you                                         2': calculated_fields.fetch(:MD502_LINE_48),
        '3': calculated_fields.fetch(:MD502_LINE_50),
        'I authorize': checkbox_value(@submission.data_source.primary_esigned_yes?),
        'ERO firm name': 'FileYourStateTaxes',
        'to enter or generate my PIN': @xml_document.at('Primary TaxpayerPIN')&.text,
        'I authorize_2': checkbox_value(@submission.data_source.spouse_esigned_yes?),
        'ERO firm name_2': @submission.data_source.spouse_esigned_yes? ? 'FileYourStateTaxes' : "",
        'to enter or generate my PIN_2': @xml_document.at('Secondary TaxpayerPIN')&.text,
        'Primary signature': signature,
        Date: @xml_document.at('Primary DateSigned')&.text,
        'Spouses signature': spouse_signature,
        Date_2: @xml_document.at('Secondary DateSigned')&.text,
      }
    end

    def checkbox_value(condition)
      condition ? 'On' : 'Off'
    end

    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
  end
end
  