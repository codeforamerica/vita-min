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
        'Line 1' => xml_value_to_pdf_checkbox('Line 1', 'E_FED_EITC_IND'),
        'Line 2' => xml_value_to_pdf_checkbox('Line 2', 'E_INV_INC_IND'),
        'Line 4' => xml_value_to_pdf_checkbox('Line 4', 'E_CHLD_CLM_IND'),
        'Line 5' => xml_value_to_pdf_checkbox('Line 5', 'E_IRS_FED_EITC_IND'),
        '6 dollars15' => claimed_attr_value('E_FED_WG_AMT'),
        '9 dollars15' => claimed_attr_value('E_FED_FEDAGI_AMT'),
        '10 dollars15' => claimed_attr_value('E_FED_EITC_CR_AMT'),
        '12 dollars15' => claimed_attr_value('E_TNTV_EITC_CR_AMT')
      }
      @submission.data_source.dependents.each_with_index do |dependent, index|
        answers.merge!({
                         "ln34fn#{index}" => dependent.first_name,
                         "ln3mi#{index}" => dependent.middle_initial,
                         "ln34ln#{index}" => dependent.last_name,
                         "ln34suf#{index}" => dependent.suffix,
                         "ln34real#{index}" => dependent.relationship,
                         "ln34ssn#{index}" => dependent.ssn,
                         "ln34birth#{index}" => dependent.dob.strftime("%m%d%Y")
                         # TODO: need to populate missing fields and compare to available information in 1040
                       })
      end
      answers
    end

    private

    FIELD_OPTIONS = {
      'Line 1' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 2' => {
        1 => 'Yes',
        2 => 'No'
      },
      'Line 4' => {
        1 => 'Yes',
        2 => 'No'
      },
      'Line 5' => {
        1 => 'Yes',
        2 => 'No'
      },
    }

    def xml_value_to_pdf_checkbox(pdf_field, xml_field)
      FIELD_OPTIONS[pdf_field][@xml_document.at(xml_field).attribute('claimed').value.to_i]
    end

    def claimed_attr_value(xml_field)
      @xml_document.at(xml_field)&.attribute('claimed')&.value
    end
  end
end
