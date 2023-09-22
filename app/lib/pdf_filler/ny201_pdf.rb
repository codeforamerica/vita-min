module PdfFiller
  class Ny201Pdf
    include PdfHelper

    def source_pdf_name
      "it201-TY2022"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.new(submission).document
    end

    def hash_for_pdf
      answers = {
        TP_first_name: @xml_document.at('tiPrime FIRST_NAME')&.text,
        TP_MI: @xml_document.at('tiPrime MI_NAME')&.text,
        TP_last_name: @xml_document.at('tiPrime LAST_NAME')&.text,
        TP_DOB: @xml_document.at('PR_DOB_DT')&.attribute('claimed')&.value,
        TP_SSN: @xml_document.at('EXT_TP_ID')&.text,
        Spouse_first_name: @xml_document.at('tiSpouse FIRST_NAME')&.text,
        Spouse_MI: @xml_document.at('tiSpouse MI_NAME')&.text,
        Spouse_last_name: @xml_document.at('tiSpouse LAST_NAME')&.text,
        Spouse_DOB: @xml_document.at('tiSpouse SP_DOB_DT')&.text,
        Spouse_SSN: @xml_document.at('tiSpouse SP_SSN_NMBR')&.text,
        TP_mail_address: @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text, # TODO: Awaiting changes in The Spreadsheet
        NYS_county_residence: @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text, # TODO: Prolly not the right field
        TP_mail_city: @xml_document.at('tiPrime MAIL_CITY_ADR')&.text,
        TP_mail_zip: @xml_document.at('tiPrime MAIL_ZIP_5_ADR')&.text,
        TP_mail_country: @xml_document.at('tiPrime COUNTY_CD')&.text,
        SD_name: @xml_document.at('tiPrime SCHOOL_NAME')&.text,
        TP_home_address: @xml_document.at('tiPrime PERM_LN_1_ADR')&.text,
        SD_code: @xml_document.at('tiPrime SCHOOL_CD')&.text,
        TP_home_city: @xml_document.at('tiPrime PERM_CTY_ADR')&.text,
        TP_home_zip: @xml_document.at('tiPrime PERM_ZIP_ADR')&.text,
        Filing_status: xml_value_to_pdf_checkbox('Filing_status', "FS_CD"),
        Itemized: xml_value_to_pdf_checkbox('Itemized', 'FED_ITZDED_IND'),
        Dependent: xml_value_to_pdf_checkbox('Dependent', 'DEP_CLAIM_IND')
      }
      answers.merge!(dependents_info(@submission.data_source.dependents))
      answers
    end

    private

    FIELD_OPTIONS = {
      'Dependent' => {
        1 => 'yes',
        2 => 'no',
      },
      'Filing_status' => {
        1 => '1 Single',
        2 => '2 Married Filing Joint Return (enter spouse’s social security number above)',
        3 => '3 Married Filing Seperate Return (enter spouse’s social security number above)',
        4 => 'Head of Household (with qualifying person)',
        5 => 'Qualifying widow(er) with dependent child',
      },
      'Itemized' => {
        1 => 'yes',
        2 => 'no',
      },
    }

    def xml_value_to_pdf_checkbox(pdf_field, xml_field)
      FIELD_OPTIONS[pdf_field][@xml_document.at(xml_field).attribute('claimed').value.to_i]
    end

    def dependents_info(dependents)
      if dependents.length > 7
        raise "Can't handle #{dependents.length} dependents yet!"
      end

      answers = {}
      dependents.each_with_index do |dependent, index|
        index = index + 1

        answers["H_first#{index}"] = dependent.first_name
        answers["H_middle#{index}"] = dependent.middle_initial
        answers["H_last#{index}"] = dependent.last_name
        answers["H_relationship#{index}"] = dependent.relationship
        answers["H_dependent_ssn#{index}"] = dependent.ssn
        answers["H_dependent_dob#{index}"] = dependent.dob.strftime("%m/%d/%Y")
      end
      answers
    end
  end
end
