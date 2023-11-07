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
        '12 dollars15' => claimed_attr_value('E_TNTV_EITC_CR_AMT'),
        '13 dollars15' => claimed_attr_value('E_TX_B4CR_AMT'),
        '14 dollars15' => claimed_attr_value('E_HH_CR_AMT'),
        '15 dollars15' => claimed_attr_value('E_EITC_LMT_AMT'),
        '16 dollars15' => claimed_attr_value('E_EITC_CR_AMT'),
        '27 dollars15' => claimed_attr_value('E_NYC_EITC_CR_AMT'),
        'Worksheet B 1 dollars15' => claimed_attr_value('E_TX_AMT'),
        'Worksheet B 2 dollars15' => claimed_attr_value('E_RSDT_CR_AMT'),
        'Worksheet B 3 dollars15' => claimed_attr_value('E_ACM_DIST_AMT'),
        'Worksheet B 4 dollars15' => claimed_attr_value('E_TOT_OTHCR_AMT'),
        'Worksheet B 5 dollars15' => claimed_attr_value('E_NET_TX_AMT')
      }
      @xml_document.css('dependent').each_with_index do |dependents_node, index|
        index += 1
        answers.merge!({
                         "ln34fn#{index}" => dependents_node.at("DEP_CHLD_FRST_NAME")&.text,
                         "ln3mi#{index}" => dependents_node.at("DEP_CHLD_MI_NAME")&.text,
                         "ln34ln#{index}" => dependents_node.at("DEP_CHLD_LAST_NAME")&.text,
                         "ln34suf#{index}" => dependents_node.at("DEP_CHLD_SFX_NAME")&.text,
                         "ln34real#{index}" => dependents_node.at("DEP_RELATION_DESC")&.text,
                         "month#{index}" => dependents_node.at("DEP_MNTH_LVD_NMBR")&.text,
                         "ln34disability#{index}" =>  dependents_node.at("DEP_DISAB_IND")&.text == '1' ? "Yes" : "Off",
                         "ln34student#{index}" =>  dependents_node.at("DEP_STUDENT_IND")&.text == '1' ? "Yes" : "Off",
                         "ln34ssn#{index}" => dependents_node.at("DEP_SSN_NMBR")&.text,
                         "ln34birth#{index}" => (Date.parse(dependents_node.at("DOB_DT")&.text)).strftime("%m%d%Y")
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
