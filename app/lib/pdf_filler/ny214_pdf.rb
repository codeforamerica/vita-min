module PdfFiller
  class Ny214Pdf
    include PdfHelper

    def source_pdf_name
      "it214-TY2023"
    end

    def nys_form_type
      "214"
    end

    delegate :tax_year, to: :@submission

    def barcode_overlay_rect
      [[0, 26], 125, 29]
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2023::States::Ny::IndividualReturn.new(submission).document
      @calculator = submission.data_source.tax_calculator
      @calculator.calculate
    end

    def hash_for_pdf
      answers = {
        'Your first name' => @submission.data_source.primary.first_name,
        'Your MI' => @submission.data_source.primary.middle_initial,
        'Your last name' => @submission.data_source.primary.last_name,
        'Your DOB' =>  @submission.data_source.primary.birth_date.strftime("%m%d%Y"),
        'Your SSN' => @submission.data_source.primary.ssn,
        'Spouse\'s first name' => @submission.data_source.spouse&.first_name,
        'Spouse\'s MI' => @submission.data_source.spouse&.middle_initial,
        'Spouse\'s last name' => @submission.data_source.spouse&.last_name,
        'Spouse DOB' =>  @submission.data_source.spouse&.birth_date&.strftime("%m%d%Y"),
        'Spouse\'s SSN' => @submission.data_source.spouse&.ssn,
        'Mailing address' => @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text,
        'NY State county of residence' =>  @submission.data_source.residence_county,
        'City, village or post office 1' => @xml_document.at('tiPrime MAIL_CITY_ADR')&.text,
        'State 1' => @submission.data_source.mailing_state,
        'ZIPcode 1' => @xml_document.at('tiPrime MAIL_ZIP_5_ADR')&.text,
        'Country' => @submission.data_source.mailing_country,
        'permanent home address' => @submission.data_source.ny_mailing_street,
        'Apartment number 2' => @submission.data_source.ny_mailing_apartment,
        'city, village or post office 2' => @submission.data_source.ny_mailing_city,
        'zip code 2' => @submission.data_source.ny_mailing_zip,
        'Line 1' => xml_value_to_pdf_checkbox('Line 1', 'R_RSDT_IND'),
        'Line 2' => xml_value_to_pdf_checkbox('Line 2', 'R_OCCPY_RSDT_IND'),
        'Line 3' => xml_value_to_pdf_checkbox('Line 3', 'R_RL_PROP_VL_IND'),
        'Line 4' => xml_value_to_pdf_checkbox('Line 4', 'R_DEPDT_IND'),
        'Line 5' => xml_value_to_pdf_checkbox('Line 5', 'R_RSDT_EXMPT_IND'),
        'Line 6' => xml_value_to_pdf_checkbox('Line 6', 'R_NRS_HOME_IND'),
        '9 dollars14' => claimed_attr_value('R_FEDAGI_AMT'),
        '10 dollars14' => claimed_attr_value('R_NYS_ADD_AMT'),
        '11 dollars14' => claimed_attr_value('R_SSINC_AMT'),
        '12 dollars14' => claimed_attr_value('R_SPLM_INC_AMT'),
        '13 dollars14' => claimed_attr_value('R_PNSN_AMT'),
        '14 dollars14' => claimed_attr_value('R_PUB_RELIEF_AMT'),
        '15 dollars14' => claimed_attr_value('R_OTHINC_AMT'),
        '16 dollars14' => claimed_attr_value('R_GRSS_INC_R_AMT'),
        '17 number14' => claimed_attr_value('R_GRSS_INC_PCT'),
        '18 dollars14' => claimed_attr_value('R_GRSS_AVL_AMT'),
        '19 dollars14' => claimed_attr_value('R_RENT_PD_AMT'),
        '20 dollars14' => claimed_attr_value('R_ADJ_AMT'),
        '21 dollars14' => claimed_attr_value('R_ADJ_RENT_AMT'),
        '22 dollars14' => claimed_attr_value('R_RENT_TX_AMT'),
        '23 dollars14' => claimed_attr_value('R_RL_PROP_TXPD_AMT'),
        '24 dollars14' => claimed_attr_value('R_ASMT_AMT'),
        '25 dollars14' => claimed_attr_value('R_B4_EXMPT_AMT'),
        '27 dollars14' => claimed_attr_value('R_HOME_RPTX_AMT'),
        '28 dollars14' => claimed_attr_value('R_RL_PROP_TX_AMT'),
        '29 dollars14' => claimed_attr_value('R_GRSS_AVL_AMT'),
        '30 dollars14' => claimed_attr_value('R_TNTV_RL_CR_AMT'),
        '31 dollars14' => claimed_attr_value('R_TX_AVL_CR_AMT'),
        '32 dollars14' => claimed_attr_value('R_CR_LMT_AMT'),
        '33 dollars14' => claimed_attr_value('R_RL_PROP_CR_AMT'),
      }
    end

    private

    FIELD_OPTIONS = {
      'Line 1' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 2' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 3' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 4' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 5' => {
        1 => 'Yes',
        2 => 'No',
      },
      'Line 6' => {
        1 => 'Yes',
        2 => 'No',
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
