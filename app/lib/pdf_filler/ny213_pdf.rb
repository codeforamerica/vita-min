module PdfFiller
  class Ny213Pdf
    include PdfHelper

    def source_pdf_name
      "it213-TY2022"
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
        'Spouse \'s last name' => @submission.data_source.spouse.full_name,
        'Spouse \'s SSN' => @submission.data_source.spouse.ssn,
        'Line 1' => xml_value_to_pdf_checkbox('Line 1', 'ESC_RSDT_IND'),
        'Line 2' => xml_value_to_pdf_checkbox('Line 2', 'ESC_FED_CR_IND'),
        'Line 3' => xml_value_to_pdf_checkbox('Line 3', 'ESC_FAGI_LMT_IND'),
        'Line 4' => claimed_attr_value('ESC_FED_CHLD_NMBR'),
        'Line 5' => claimed_attr_value('ESC_QUAL_CHLD_NMBR'),
      }

      if @submission.data_source.dependents.length > 6
        raise "Too many dependents to handle on IT213!"
      end

      @submission.data_source.dependents.select { |d| d.dob >= 17.years.ago }.each_with_index do |dependent, index|
        index += 1
        answers.merge!({
                         "First Name #{index}" => dependent.first_name,
                         "MI #{index}" => dependent.middle_initial,
                         "Last Name #{index}" => dependent.last_name,
                         "Suffix #{index}" => dependent.suffix,
                         "SSN #{index}" => dependent.ssn,
                         "Year of Birth #{index}" => dependent.dob.strftime("%m%d%Y")
                       })
      end


      answers.merge!(
        'Line 6 Dollars' => claimed_attr_value('ESC_FED_CR_AMT'),
        'Line 7 Dollars' => claimed_attr_value('ESC_FED_ADDL_AMT'),
        'Line 8 Dollars' => claimed_attr_value('ESC_FED_TOT_AMT'),
      )

      if @xml_document.at('ESC_FED_AVG_AMT')
        answers.merge!(
          'Line 9' => claimed_attr_value('ESC_FED_CHLD_NMBR'),
          'Line 10 Dollars' => claimed_attr_value('ESC_FED_AVG_AMT'),
          'Line 11' => claimed_attr_value('ESC_QUAL_CHLD_NMBR'),
          'Line 12 Dollars' => claimed_attr_value('ESC_AVL_BASE_AMT'),
        )
      end

      answers.merge!(
        'Line 13 Dollars' => claimed_attr_value('ESC_LMT_1_AMT'),
      )

      if @xml_document.at('ESC_LMT_2_AMT')
        answers.merge!(
          'Line 14' => claimed_attr_value('ESC_QUAL_CHLD_NMBR'),
          'Line 15 Dollars' => claimed_attr_value('ESC_LMT_2_AMT'),
        )
      end

      answers.merge!(
        'Line 16 Dollars' => claimed_attr_value('ESC_CHLD_CR_AMT'),
      )
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
      'Line 3' => {
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
