# frozen_string_literal: true

module StateFile
  class StateInformationService
    GETTER_METHODS = [
      :intake_class,
      :calculator_class,
      :check_box_16,
      :filing_years,
      :mail_voucher_address,
      :navigation_class,
      :pay_taxes_link,
      :return_type,
      :review_controller_class,
      :schema_file_name,
      :software_id_key,
      :submission_builder_class,
      :submission_type,
      :survey_link,
      :taxes_due_dates_payment_info,
      :tax_payment_info_url,
      :tax_payment_info_text,
      :tax_refund_url,
      :timezone,
      :vita_link_en,
      :vita_link_es,
      :voucher_form_name,
      :voucher_path,
      :w2_supported_box14_codes,
      :w2_include_local_income_boxes,
      :auto_calculate_withdraw_amount,
    ].freeze

    class << self
      GETTER_METHODS.each do |attribute|
        define_method(attribute) do |state_code|
          unless STATES_INFO.key?(state_code)
            raise InvalidStateCodeError, state_code
          end

          STATES_INFO[state_code][attribute]
        end
      end

      def state_name(state_code)
        raise InvalidStateCodeError, state_code unless STATES_INFO.key?(state_code)
        I18n.t("state_file.state_information_service.#{state_code}.state_name")
      end

      def department_of_taxation(state_code)
        raise InvalidStateCodeError, state_code unless STATES_INFO.key?(state_code)
        I18n.t("state_file.state_information_service.#{state_code}.department_of_taxation")
      end

      def survey_link(state_code, locale: nil)
        raise InvalidStateCodeError, state_code unless STATES_INFO.key?(state_code)
        I18n.t("state_file.state_information_service.#{state_code}.survey_link", locale: locale || I18n.locale)
      end

      # Returns the state-specific date in the current filing year only - no time or timezone.
      # Since MD's payment deadline changes after tax day, the datetime param is used to find what the deadline is on a given day
      # Ex: 2025-04-15
      def payment_deadline_date(state_code, time = Time.current)
        time ||= Time.current
        return get_md_payment_deadline(time) if state_code == "md"
        Rails.configuration.tax_deadline.to_date
      end

      # Check if the day of a given DateTime is before the payment deadline date, using the state-specific/government timezone
      def before_payment_deadline?(datetime, state_code)
        payment_deadline_date = StateInformationService.payment_deadline_date(state_code, datetime)
        timezone = StateInformationService.timezone(state_code)
        datetime.in_time_zone(timezone).to_date.before?(payment_deadline_date)
      end

      # Check if the day of a given DateTime is after the tax deadline date, using the state-specific/government timezone
      def after_payment_deadline?(time, state_code)
        timezone = StateInformationService.timezone(state_code)
        deadline = Rails.configuration.tax_deadline.to_date
        time.in_time_zone(timezone).to_date.after?(deadline)
      end

      # Maryland has different payment deadline logic from all our other States
      # 1. If filing before April 16: payment can be scheduled until April 30th
      # 2. If filing on or after April 16: payment cannot be scheduled (same as other States)
      def get_md_payment_deadline(time)
        timezone = StateInformationService.timezone("md")
        day_after_deadline = Rails.configuration.tax_deadline.to_date + 1.day
        on_or_before_deadline = time.in_time_zone(timezone).to_date.before?(day_after_deadline)

        return Date.new(time.year, 4, 30) if on_or_before_deadline
        day_after_deadline
      end

      def active_state_codes
        @_active_state_codes ||= STATES_INFO.keys.map(&:to_s).freeze
      end

      def state_code_to_name_map
        @_state_code_to_name_map ||= active_state_codes.to_h { |state_code, _| [state_code, state_name(state_code)] }.freeze
      end

      def state_intake_classes
        @_state_intake_classes ||= STATES_INFO.map { |_, attrs| attrs[:intake_class] }.freeze
      end

      def state_intake_class_names
        @_state_intake_class_names ||= state_intake_classes.map(&:to_s).freeze
      end
    end

    STATES_INFO = IceNine.deep_freeze!({
      az: {
        intake_class: StateFileAzIntake,
        calculator_class: Efile::Az::Az140Calculator,
        check_box_16: false,
        filing_years: [2024, 2023],
        mail_voucher_address: "Arizona Department of Revenue<br/>" \
                              "PO Box 29085<br/>" \
                              "Phoenix, AZ 85038-9085".html_safe,
        navigation_class: Navigation::StateFileAzQuestionNavigation,
        pay_taxes_link: "https://www.aztaxes.gov/",
        return_type: "Form140",
        review_controller_class: StateFile::Questions::AzReviewController,
        schema_file_name: "AZIndividual2024v2.1.zip",
        software_id_key: "sin",
        submission_builder_class: SubmissionBuilder::Ty2022::States::Az::AzReturnXml,
        survey_link: I18n.t("state_file.state_information_service.az.survey_link"),
        submission_type: "Form140",
        taxes_due_dates_payment_info: "AZTaxes.gov/Home/PaymentIndividual",
        tax_payment_info_text: "https://azdor.gov/make-payment-online",
        tax_payment_info_url: "https://azdor.gov/making-payments-late-payments-and-filing-extensions",
        tax_refund_url: "https://aztaxes.gov/home/checkrefund",
        timezone: 'America/Phoenix',
        vita_link_en: "https://airtable.com/appMTIDgfgmMZjPqh/pag78AN26G3oA2i9q/form",
        vita_link_es: " https://airtable.com/appMTIDgfgmMZjPqh/pagpZYWNWu2uH2JZh/form",
        voucher_form_name: "Form AZ-140V",
        voucher_path: "/pdfs/AZ-140V.pdf",
        w2_supported_box14_codes: [],
        w2_include_local_income_boxes: false,
        auto_calculate_withdraw_amount: false
      },
      id: {
        intake_class: StateFileIdIntake,
        calculator_class: Efile::Id::Id40Calculator,
        check_box_16: false,
        filing_years: [2024],
        mail_voucher_address: "Idaho State Tax Commission<br/>" \
                              "PO Box 83784<br/>" \
                              "Boise ID 83707-3784".html_safe,
        navigation_class: Navigation::StateFileIdQuestionNavigation,
        pay_taxes_link: "https://tax.idaho.gov/online-services/e-pay/",
        return_type: "Form40",
        review_controller_class: StateFile::Questions::IdReviewController,
        schema_file_name: "ID_MeF2024V0.1.zip",
        software_id_key: "sin",
        submission_type: "Form40",
        submission_builder_class: SubmissionBuilder::Ty2024::States::Id::IdReturnXml,
        survey_link: I18n.t("state_file.state_information_service.id.survey_link"),
        taxes_due_dates_payment_info: "https://tax.idaho.gov/",
        tax_payment_info_text: "https://tax.idaho.gov/e-pay/",
        tax_payment_info_url: "https://tax.idaho.gov/online-services/e-pay/",
        tax_refund_url: "https://tax.idaho.gov/taxes/income-tax/individual-income/refund/",
        timezone: 'America/Boise',
        vita_link_en: "https://airtable.com/appqG5OGbTLBiQ408/pagt2JWaKQRG5I0gl/form",
        vita_link_es: "https://airtable.com/appqG5OGbTLBiQ408/pagTE56DjYpVNc5pX/form",
        voucher_form_name: "Form ID-VP",
        voucher_path: "/pdfs/idformIDVP-TY2024.pdf",
        w2_supported_box14_codes: [],
        w2_include_local_income_boxes: false,
        auto_calculate_withdraw_amount: false
      },
      md: {
        intake_class: StateFileMdIntake,
        calculator_class: Efile::Md::Md502Calculator,
        check_box_16: false,
        filing_years: [2024],
        mail_voucher_address: "Comptroller of Maryland<br/>" \
                              "Payment Processing<br/>" \
                              "PO Box 8888<br/>" \
                              "Annapolis, MD 21401-8888".html_safe,
        navigation_class: Navigation::StateFileMdQuestionNavigation,
        pay_taxes_link: "https://www.marylandtaxes.gov/individual/individual-payments.php",
        return_type: "502",
        review_controller_class: StateFile::Questions::MdReviewController,
        schema_file_name: "MDIndividual2024v1.0.zip",
        software_id_key: "md_sin", # MD assigned us a unique software id only in use for MD
        submission_type: "MD502",
        submission_builder_class: SubmissionBuilder::Ty2024::States::Md::MdReturnXml,
        survey_link: I18n.t("state_file.state_information_service.md.survey_link"),
        taxes_due_dates_payment_info: "Marylandtaxes.gov",
        tax_payment_info_text: "Marylandtaxes.gov",
        tax_payment_info_url: "https://www.marylandtaxes.gov/individual/individual-payments.php",
        tax_refund_url: "https://interactive.marylandtaxes.gov/INDIV/refundstatus/home.aspx",
        timezone: 'America/New_York',
        vita_link_en: "https://airtable.com/appAgBw351Iig0YI4/pagVvtGPWrpURJrrd/form",
        vita_link_es: "https://airtable.com/appAgBw351Iig0YI4/pagpUP2HSWNXzPlIz/form",
        voucher_form_name: "Form PV",
        voucher_path: "/pdfs/md-pv-TY2024.pdf",
        w2_supported_box14_codes: [{name: "STPICKUP"}],
        w2_include_local_income_boxes: true,
        auto_calculate_withdraw_amount: false
      },
      nc: {
        intake_class: StateFileNcIntake,
        calculator_class: Efile::Nc::D400Calculator,
        check_box_16: false,
        filing_years: [2024],
        mail_voucher_address: "North Carolina Department of Revenue<br/>" \
                              "PO Box 25000<br/>" \
                              "Raleigh, NC 27640-0640".html_safe,
        navigation_class: Navigation::StateFileNcQuestionNavigation,
        pay_taxes_link: "https://electronic-services.dor.nc.gov/wps/portal/d400v",
        return_type: "FormNCD400",
        review_controller_class: StateFile::Questions::NcReviewController,
        schema_file_name: "NCIndividual2024v1.0.zip",
        software_id_key: "sin",
        submission_type: "FormNCD400",
        submission_builder_class: SubmissionBuilder::Ty2024::States::Nc::NcReturnXml,
        survey_link: I18n.t("state_file.state_information_service.nc.survey_link"),
        tax_payment_info_text: "NCDOR.gov",
        taxes_due_dates_payment_info: "",
        tax_payment_info_url: "https://www.ncdor.gov/file-pay/pay-individual-income-tax",
        tax_refund_url: "https://eservices.dor.nc.gov/wheresmyrefund/SelectionServlet",
        timezone: 'America/New_York',
        vita_link_en: "https://airtable.com/appqG5OGbTLBiQ408/pagJPN5iPinERGb3Q/form",
        vita_link_es: "https://airtable.com/appqG5OGbTLBiQ408/pagS982AjKEml809R/form",
        voucher_form_name: "Form D-400V",
        voucher_path: "https://eservices.dor.nc.gov/vouchers/d400v.jsp?year=2024",
        w2_supported_box14_codes: [],
        w2_include_local_income_boxes: false,
        auto_calculate_withdraw_amount: false
      },
      nj: {
        intake_class: StateFileNjIntake,
        calculator_class: Efile::Nj::Nj1040Calculator,
        check_box_16: true,
        filing_years: [2024],
        navigation_class: Navigation::StateFileNjQuestionNavigation,
        review_controller_class: StateFile::Questions::NjReviewController,
        submission_builder_class: SubmissionBuilder::Ty2024::States::Nj::NjReturnXml,
        software_id_key: "sin",
        return_type: "Resident",
        schema_file_name: "NJIndividual2024V0.1.zip",
        mail_voucher_address: "State of New Jersey<br/>" \
                              "Division of Taxation<br/>" \
                              "Revenue Processing Center - Payments<br/>" \
                              "PO Box 643 Trenton, NJ 08646-0643".html_safe,
        pay_taxes_link: "https://www1.state.nj.us/TYTR_RevTaxPortal/jsp/IndTaxLoginJsp.jsp",
        survey_link: I18n.t("state_file.state_information_service.nj.survey_link"),
        submission_type: "Resident",
        taxes_due_dates_payment_info: "",
        tax_payment_info_text: "https://www1.state.nj.us/TYTR_RevTaxPortal/jsp/IndTaxLoginJsp.jsp",
        tax_payment_info_url: "https://www.state.nj.us/treasury/taxation/payments-notices.shtml",
        tax_refund_url: "https://www.nj.gov/treasury/taxation/checkrefundstatus.shtml",
        timezone: 'America/New_York',
        vita_link_en: "https://airtable.com/appqG5OGbTLBiQ408/pag9EUHzAZzfRIwUn/form",
        vita_link_es: "https://airtable.com/appqG5OGbTLBiQ408/pagVcLm52Stg9p4hY/form",
        voucher_form_name: "NJ-1040-V (NJ Gross Income Tax Resident Payment Voucher)",
        voucher_path: "/pdfs/nj1040v-TY2024.pdf",
        w2_supported_box14_codes: [{name: "UI_WF_SWF", limit: 180}, {name: "FLI", limit: 145.26}],
        w2_include_local_income_boxes: false,
        auto_calculate_withdraw_amount: true
      },
      ny: {
        intake_class: StateFileNyIntake,
        calculator_class: Efile::Ny::It201,
        check_box_16: false,
        filing_years: [2023],
        mail_voucher_address: "NYS Personal Income Tax<br/>" \
                              "Processing Center<br/>" \
                              "Box 4124<br/>" \
                              "Binghamton, NY 13902-4124".html_safe,
        navigation_class: Navigation::StateFileNyQuestionNavigation,
        pay_taxes_link: "https://www.tax.ny.gov/pay/",
        return_type: "IT201",
        review_controller_class: StateFile::Questions::NyReviewController,
        submission_type: "IT201",
        schema_file_name: "NYSIndividual2023V4.0.zip",
        software_id_key: "sin",
        submission_builder_class: SubmissionBuilder::Ty2022::States::Ny::NyReturnXml,
        survey_link: I18n.t("state_file.state_information_service.ny.survey_link"),
        taxes_due_dates_payment_info: "",
        tax_payment_info_text: "Tax.NY.gov",
        tax_payment_info_url: "https://www.tax.ny.gov/pay/ind/pay-income-tax-online.htm",
        tax_refund_url: "https://www.tax.ny.gov/pit/file/refund.htm",
        timezone: 'America/New_York',
        vita_link_en: "",
        vita_link_es: "",
        voucher_form_name: "Form IT-201-V",
        voucher_path: "/pdfs/it201v_1223.pdf",
        w2_supported_box14_codes: [],
        w2_include_local_income_boxes: false,
        auto_calculate_withdraw_amount: false
      }
    }.with_indifferent_access)
  end
end
