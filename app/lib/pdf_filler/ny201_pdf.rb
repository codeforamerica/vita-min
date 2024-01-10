module PdfFiller
  class Ny201Pdf
    include PdfHelper

    def source_pdf_name
      "it201-TY2023"
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
        TP_DOB: @submission.data_source.primary&.birth_date&.strftime("%m%d%Y"),
        TP_SSN: @xml_document.at('EXT_TP_ID')&.text,
        Spouse_first_name: @xml_document.at('tiSpouse FIRST_NAME')&.text,
        Spouse_MI: @xml_document.at('tiSpouse MI_NAME')&.text,
        Spouse_last_name: @xml_document.at('tiSpouse LAST_NAME')&.text,
        Spouse_DOB: @submission.data_source.spouse&.birth_date&.strftime("%m%d%Y"),
        Spouse_SSN: @xml_document.at('tiSpouse SP_SSN_NMBR')&.text,
        TP_mail_address: @xml_document.at('tiPrime MAIL_LN_2_ADR')&.text,
        TP_mail_apt: @xml_document.at('tiPrime MAIL_LN_1_ADR')&.text,
        NYS_county_residence: @xml_document.at('tiPrime COUNTY_NAME')&.text,
        TP_mail_city: @xml_document.at('tiPrime MAIL_CITY_ADR')&.text,
        TP_mail_state: @xml_document.at('tiPrime MAIL_STATE_ADR')&.text,
        TP_mail_zip: @xml_document.at('tiPrime MAIL_ZIP_5_ADR')&.text,
        TP_mail_country: 'United Sates',
        TP_home_address: @xml_document.at('tiPrime PERM_LN_2_ADR')&.text,
        TP_home_apt: @xml_document.at('tiPrime PERM_LN_1_ADR')&.text,
        TP_home_city: @xml_document.at('tiPrime PERM_CTY_ADR')&.text,
        TP_home_zip: @xml_document.at('tiPrime PERM_ZIP_ADR')&.text,
        SD_name: @xml_document.at('tiPrime SCHOOL_NAME')&.text,
        SD_code: @xml_document.at('tiPrime SCHOOL_CD')&.text,
        Filing_status: xml_value_to_pdf_checkbox('Filing_status', "FS_CD"),
        Itemized: xml_value_to_pdf_checkbox('Itemized', 'FED_ITZDED_IND'),
        Dependent: xml_value_to_pdf_checkbox('Dependent', 'DEP_CLAIM_IND'),
        Foreign_account: xml_value_to_pdf_checkbox('Foreign_account', 'FORGN_ACCT_IND'),
        yonkers_freeze_credit: xml_value_to_pdf_checkbox('yonkers_freeze_credit', 'YNK_LVNG_QTR_IND'),
        E1: xml_value_to_pdf_checkbox('E1', 'NYC_LVNG_QTR_IND'),
        F1_NYC: claimed_attr_value('PR_NYC_MNTH_NMBR'),
        F2_NYC: claimed_attr_value('SP_NYC_MNTH_NMBR'),
      }
      if @submission.data_source.nyc_full_year_resident_yes?
        answers[:F1_NYC] = '12'
        if @submission.data_source.filing_status_mfj?
          answers[:F2_NYC] = '12'
        end
      end
      answers.merge!(dependents_info(@submission.data_source.dependents))
      answers.merge!(
        Line1: claimed_attr_value('WG_AMT'),
        Line2: claimed_attr_value('INT_AMT'),
        Line14: claimed_attr_value('TX_UNEMP_AMT'),
        Line15: claimed_attr_value('SSINC_AMT'),
        Line17: claimed_attr_value('FEDAGI_B4_ADJ_AMT'),
        "18_identify" => fed_adjustments_identify,
        Line18: claimed_attr_value('FEDADJ_AMT'),
        Line19: claimed_attr_value('FEDAGI_AMT'),
        Line21: claimed_attr_value('A_PBEMP_AMT'),
        Line23: claimed_attr_value('A_OTH_AMT'),
        Line24: claimed_attr_value('A_SUBTL_AMT'),
        Line27: claimed_attr_value('S_TXBL_SS_AMT'),
        Line32: claimed_attr_value('S_SUBTL_AMT'),
        Line33: claimed_attr_value('NYSAGI_AMT'),
        "34Deduction" => xml_value_to_pdf_checkbox("34Deduction", 'STD_ITZ_IND'),
        Line34: claimed_attr_value('DED_AMT'),
        Line35: claimed_attr_value('INC_B4_EXMPT_AMT'),
        Line36: claimed_attr_value('EXMPT_NMBR'),
        Line37: claimed_attr_value('TXBL_INC_AMT'),
        Line38: claimed_attr_value('TXBL_INC_AMT'),
        Line39: claimed_attr_value('TX_B4CR_AMT'),
        Line40: claimed_attr_value('HH_CR_AMT'),
        Line43: claimed_attr_value('TOT_NRFNDCR_AMT'),
        Line44: claimed_attr_value('TX_AFT_NRFNDCR_AMT'),
        Line46: claimed_attr_value('TOT_TX_AMT'),
        Line47: claimed_attr_value('NYC_TXBL_INC_AMT'),
        Line47a: claimed_attr_value('NYC_TX_B4CR_AMT'),
        Line48: claimed_attr_value('NYC_HH_CR_AMT'),
        Line49: claimed_attr_value('NYC_TX_AFT_HH_AMT'),
        Line52: claimed_attr_value('NYC_TOT_TX_AMT'),
        Line54: claimed_attr_value('NYC_TAX_AFT_CR_AMT'),
        Line58: claimed_attr_value('NYC_YNK_NET_TX_AMT'),
        Line59: claimed_attr_value('SALE_USE_AMT'),
        Line61: claimed_attr_value('TX_GFT_AMT'),
        Line62: claimed_attr_value('TX_GFT_AMT'),
        Line63: claimed_attr_value('ESC_CHLD_CR_AMT'),
        Line65: claimed_attr_value('EITC_CR_AMT'),
        Line67: claimed_attr_value('RL_PROP_CR_AMT'),
        Line69: claimed_attr_value('NYC_STAR_CR_AMT'),
        Line69a: claimed_attr_value('NYC_STAR_REDCR_AMT'),
        Line70: claimed_attr_value('NYC_EITC_CR_AMT'),
        Line72: claimed_attr_value('TOT_WTHLD_AMT'),
        Line73: claimed_attr_value('TOT_NYC_WTHLD_AMT'),
        Line76: claimed_attr_value('TOT_PAY_AMT'),
        Line77: claimed_attr_value('OVR_PAID_AMT'),
        Line78: claimed_attr_value('RFND_B4_EDU_AMT'),
        Line78b: claimed_attr_value('RFND_AMT'),
        # TODO - direct deposit or check checkbox, indicated by a single linked field in the PDF but 2 separate fields in the XML,
        # Line78_refund:
        # TODO - 'to pay by electronic funds withdrawal' checkbox. not 100% confident what it maps to in the xml
        # Line80_box: ,
        Line80: claimed_attr_value('BAL_DUE_AMT'),
      )
      unless @xml_document.at('ACCT_TYPE_CD').nil?
        answers.merge!(
          Line83a_account: xml_value_to_pdf_checkbox("Line83a_account", 'ACCT_TYPE_CD'),
          Line83b_routing: claimed_attr_value('ABA_NMBR'),
          Line83c_account_num: claimed_attr_value('BANK_ACCT_NMBR'),
          Line84_withdrawal_Date: claimed_attr_value('ELC_AUTH_EFCTV_DT'),
          Line84_withdrawal_amount: claimed_attr_value('PYMT_AMT'),
        )
      end
      answers
    end

    private

    FIELD_OPTIONS = {
      '34Deduction' => {
        1 => "Standard",
        2 => "Itemized",
      },
      'Dependent' => {
        1 => 'yes',
        2 => 'no',
      },
      'Filing_status' => {
        1 => '1 Single',
        2 => '2 Married Filing Joint Return',
        3 => '3 Married Filing Separate Return',
        4 => 'Head of Household (with qualifying person)',
        5 => 'Qualifying widow(er) with dependent child',
      },
      'Itemized' => {
        1 => 'yes',
        2 => 'no',
      },
      'Foreign_account' => {
        1 => 'yes',
        2 => 'no',
      },
      'yonkers_freeze_credit' => {
        1 => 'yes',
        2 => 'no',
      },
      'E1' => {
        1 => 'yes',
        2 => 'no',
      },
      'Line78_refund' => {
        'TODO1' => 'direct deposit',
        'TODO2' => 'check',
      },
      'Line83a_account' => {
        "TODO1" => "business checking",
        "TODO2" => "business savings",
        1 => "personal checking",
        2 => "personal savings"
      }
    }

    def xml_value_to_pdf_checkbox(pdf_field, xml_field)
      FIELD_OPTIONS[pdf_field][@xml_document.at(xml_field).attribute('claimed').value.to_i]
    end

    def claimed_attr_value(xml_field)
      @xml_document.at(xml_field)&.attribute('claimed')&.value
    end

    def dependents_info(dependents)
      answers = {}
      answers["H_additional_dependents"] = "yes" if dependents.length > 7
      dependents.slice(0, 7).each_with_index do |dependent, index|
        index = index + 1

        answers["H_first#{index}"] = dependent.first_name
        answers["H_middle#{index}"] = dependent.middle_initial
        answers["H_last#{index}"] = dependent.last_name
        answers["H_relationship#{index}"] = dependent.relationship_label
        answers["H_dependent_ssn#{index}"] = dependent.ssn
        answers["H_dependent_dob#{index}"] = dependent.dob.strftime("%m%d%Y")
      end
      answers
    end

    def fed_adjustments_identify
      adjustments_claimed = @submission.data_source.direct_file_data.fed_adjustments_claimed.values
      adjustments_claimed.map{ |info| info[:pdf_label] }.join(", ")
    end
  end
end
