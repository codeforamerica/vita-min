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
        TP_mail_address: @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text,
        NYS_county_residence: @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text,
        TP_mail_city: @xml_document.at('tiPrime MAIL_CITY_ADR')&.text,
        TP_mail_zip: @xml_document.at('tiPrime MAIL_ZIP_5_ADR')&.text,
        TP_mail_country: @xml_document.at('tiPrime COUNTY_CD')&.text,
        SD_name: @xml_document.at('tiPrime SCHOOL_NAME')&.text,
        TP_home_address: @xml_document.at('tiPrime PERM_LN_1_ADR')&.text,
        SD_code: @xml_document.at('tiPrime SCHOOL_CD')&.text,
        TP_home_city: @xml_document.at('tiPrime PERM_CTY_ADR')&.text,
        TP_home_zip: @xml_document.at('tiPrime PERM_ZIP_ADR')&.text,
        Filing_status: filing_status,
        Itemized: "no",
        Dependent: claimed_as_dep
      }
      answers
    end

    private

    def filing_status
      # TODO: the ones with the fancy apostrophe don't fill out correctly yet
      {
        1 => '1 Single',
        2 => '2 Married Filing Joint Return (enter spouse’s social security number above)',
        3 => '3 Married Filing Seperate Return (enter spouse’s social security number above)',
        4 => 'Head of Household (with qualifying person)',
        5 => 'Qualifying widow(er) with dependent child',
      }[@xml_document.at('FS_CD').attribute('claimed').value.to_i]
    end

    def claimed_as_dep
      {
        1 => 'yes',
        2 => 'no',
      }[@xml_document.at('DEP_CLAIM_IND').attribute('claimed').value.to_i]
    end
  end
end
