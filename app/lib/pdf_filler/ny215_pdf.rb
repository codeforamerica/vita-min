module PdfFiller
  class Ny215Pdf
    include PdfHelper

    def source_pdf_name
      "it215-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = SubmissionBuilder::StateFile.from_state_code(:ny)
      @xml_document = builder.new(submission).document
      @calculator = submission.data_source.tax_calculator
      @calculator.calculate
    end

    def hash_for_pdf
      # Note: the 2023 form was updated to have lines 1, 2, 3, 4 instead of 1, 1a, 2, 3 -- but the fillable field names
      # were not updated, so line 1a = line 2 in the form, line 2 = line 3 in the form, and line 3 = line 4 in the form
      answers = {
        'Your last name' => @submission.data_source.primary.full_name,
        'Your SSN' => @submission.data_source.primary.ssn,
        'Line 1' => xml_value_to_pdf_checkbox('Line 1', 'E_FED_EITC_IND'), # Line 1
        'Line 1a' => xml_value_to_pdf_checkbox('Line 1a', 'E_INV_INC_IND'), # Line 2
        'Line 2' => xml_value_to_pdf_checkbox('Line 2', 'E_FED_FS_REQ_IND'), # Line 3
        'Line 3' => xml_value_to_pdf_checkbox('Line 3', 'E_CHLD_CLM_IND'), # Line 4
        'Line 5' => xml_value_to_pdf_checkbox('Line 5', 'E_IRS_FED_EITC_IND'), # Line 5
        '6 dollars15' => claimed_attr_value('E_FED_WG_AMT'), # Line 6
        '9 dollars15' => claimed_attr_value('E_FED_FEDAGI_AMT'), # Line 9
        '10 dollars15' => claimed_attr_value('E_FED_EITC_CR_AMT'), # Line 10
        '12 dollars15' => claimed_attr_value('E_TNTV_EITC_CR_AMT'), # Line 12
        '13 dollars15' => claimed_attr_value('E_TX_B4CR_AMT'), # Line 13
        '14 dollars15' => claimed_attr_value('E_HH_CR_AMT'), # Line 14
        '15 dollars15' => claimed_attr_value('E_EITC_LMT_AMT'), # Line 15
        '16 dollars15' => claimed_attr_value('E_EITC_CR_AMT'), # Line 16
        '27 dollars15' => claimed_attr_value('E_NYC_EITC_CR_AMT'), # Line 27
        'Worksheet B 1 dollars15' => claimed_attr_value('E_TX_AMT'),
        'Worksheet B 2 dollars15' => claimed_attr_value('E_RSDT_CR_AMT'),
        'Worksheet B 3 dollars15' => claimed_attr_value('E_ACM_DIST_AMT'),
        'Worksheet B 4 dollars15' => claimed_attr_value('E_TOT_OTHCR_AMT'),
        'Worksheet B 5 dollars15' => claimed_attr_value('E_NET_TX_AMT')
      }

      dependents = @submission.data_source.dependents.where(eic_qualifying: true)
      raise "Too many dependents to handle on IT215!" if dependents.length > 3

      dependents.each_with_index do |dependent, index|
        index += 1
        answers.merge!({
                         "ln34fn#{index}" => dependent.first_name,
                         "ln3mi#{index}" => dependent.middle_initial,
                         "ln34ln#{index}" => dependent.last_name,
                         "ln34suf#{index}" => dependent.suffix,
                         "ln34real#{index}" => dependent.relationship_label,
                         "month#{index}" => dependent.months_in_home,
                         "ln34disability#{index}" => dependent.eic_disability_yes? ? "Yes" : "Off",
                         "ln34student#{index}" => dependent.eic_student_yes? ? "Yes" : "Off",
                         "ln34ssn#{index}" => dependent.ssn,
                         "ln34birth#{index}" => dependent.dob.strftime("%m%d%Y")
                       })
      end
      answers
    end

    private

    # Note: the 2023 form was updated to have lines 1, 2, 3, 4 instead of 1, 1a, 2, 3 -- but the fillable field names
    # were not updated, so line 1a = line 2 in the form, line 2 = line 3 in the form, and line 3 = line 4 in the form
    FIELD_OPTIONS = {
      'Line 1' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 1a' => {
        1 => 'Yes',
        2 => 'No'
      },
      'Line 2' => {
        1 => 'Yes',
        2 => 'No'
      },
      'Line 3' => {
        1 => 'Yes',
        2 => 'No'
      },
      'Line 5' => {
        1 => 'Yes',
        2 => 'No'
      }
    }

    def xml_value_to_pdf_checkbox(pdf_field, xml_field)
      FIELD_OPTIONS[pdf_field][@xml_document.at(xml_field)&.attribute('claimed')&.value.to_i]
    end

    def claimed_attr_value(xml_field)
      @xml_document.at(xml_field)&.attribute('claimed')&.value
    end
  end
end
