module PdfFiller
  class Ny215Pdf
    include PdfHelper

    def source_pdf_name
      "it215-TY2022"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.new(submission).document
      @calculator = submission.data_source.tax_calculator
      @calculator.calculate
    end

    def hash_for_pdf
      answers = {
        'Your last name' => @submission.data_source.primary.full_name,
        'Your SSN' => @submission.data_source.primary.ssn,
        'Line 1' => xml_value_to_pdf_checkbox('Line 1', 'E_FED_EITC_IND')
      }
    end

    private

    FIELD_OPTIONS = {
      'Line 1' => {
        1 => 'Yes',
        2 => 'No'
      }
    }

    def xml_value_to_pdf_checkbox(pdf_field, xml_field)
      FIELD_OPTIONS[pdf_field][@xml_document.at(xml_field).attribute('claimed').value.to_i]
    end

    def claimed_attr_value(xml_field)
      @xml_document.at(xml_field)&.attribute('claimed')&.value
    end
  end
end
