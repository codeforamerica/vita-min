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

      signature = @submission.data_source.primary.full_name
      spouse_signature = @submission.data_source.spouse_esigned_yes? ? @submission.data_source.spouse.full_name : ""
      {
        'First Name': @submission.data_source.primary.first_name,
        'Primary MI': @submission.data_source.primary.middle_initial,
        'Last Name': @submission.data_source.primary.last_name_and_suffix,
        'SSNTaxpayer Identification Number': @submission.data_source.primary.ssn,
        'Spouses First Name': @submission.data_source.spouse.first_name,
        'Spouse MI': @submission.data_source.spouse.middle_initial,
        'Spouses Last Name': @submission.data_source.spouse.last_name_and_suffix,
        'SSNTaxpayer Identification Number_2': @submission.data_source.spouse.ssn,
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
  