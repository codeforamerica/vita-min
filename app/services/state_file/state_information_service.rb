# frozen_string_literal: true
module StateFile
  class StateInformationService
    GETTER_METHODS = [
      :intake_class,
      :calculator_class,
      :filing_years,
      :mail_voucher_address,
      :navigation_class,
      :pay_taxes_link,
      :return_type,
      :schema_file_name,
      :state_name,
      :submission_builder_class,
      :survey_link,
      :tax_payment_info_url,
      :tax_payment_url,
      :tax_refund_url,
      :timezone,
      :vita_link,
      :voucher_form_name,
      :voucher_path,
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

    private

    STATES_INFO = IceNine.deep_freeze!({
      az: {
        intake_class: StateFileAzIntake,
        calculator_class: Efile::Az::Az140Calculator,
        filing_years: [2024, 2023],
        mail_voucher_address: "Arizona Department of Revenue<br/>" \
                              "PO Box 29085<br/>" \
                              "Phoenix, AZ 85038-9085".html_safe,
        navigation_class: Navigation::StateFileAzQuestionNavigation,
        pay_taxes_link: "https://www.aztaxes.gov/",
        return_type: "Form140",
        schema_file_name: "AZIndividual2023v1.0.zip",
        state_name: "Arizona",
        submission_builder_class: SubmissionBuilder::Ty2022::States::Az::AzReturnXml,
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey",
        tax_payment_info_url: "https://azdor.gov/making-payments-late-payments-and-filing-extensions",
        tax_payment_url: "AZTaxes.gov",
        tax_refund_url: "https://aztaxes.gov/home/checkrefund",
        timezone: 'America/Phoenix',
        vita_link: "https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form",
        voucher_form_name: "Form AZ-140V",
        voucher_path: "/pdfs/AZ-140V.pdf",
      },
      id: {
        intake_class: StateFileIdIntake,
        calculator_class: Efile::Id::Id40Calculator,
        filing_years: [2024],
        mail_voucher_address: "",
        navigation_class: Navigation::StateFileIdQuestionNavigation,
        pay_taxes_link: "",
        return_type: "Form40",
        state_name: "Idaho",
        schema_file_name: "ID.MeF2023V1.0.zip",
        submission_builder_class: SubmissionBuilder::Ty2024::States::Id::IdReturnXml,
        survey_link: "",
        tax_payment_info_url: "",
        tax_payment_url: "",
        tax_refund_url: "",
        timezone: 'America/Boise',
        vita_link: "",
        voucher_form_name: "",
        voucher_path: "",
      },
      md: {
        intake_class: StateFileMdIntake,
        calculator_class: Efile::Md::Md502Calculator,
        filing_years: [2024],
        mail_voucher_address: "".html_safe,
        navigation_class: Navigation::StateFileMdQuestionNavigation,
        pay_taxes_link: "",
        return_type: "Form502",
        schema_file_name: "MDIndividual2023v1.0.zip",
        state_name: "Maryland",
        submission_builder_class: SubmissionBuilder::Ty2024::States::Md::MdReturnXml,
        survey_link: "",
        tax_payment_info_url: "",
        tax_payment_url: "",
        tax_refund_url: "",
        timezone: 'America/New_York',
        vita_link: "",
        voucher_form_name: "",
        voucher_path: "",
      },
      nc: {
        intake_class: StateFileNcIntake,
        calculator_class: Efile::Nc::D400Calculator,
        filing_years: [2024],
        mail_voucher_address: "North Carolina Department of Revenue<br/>" \
                              "PO Box 25000<br/>" \
                              "Raleigh, NC 27640-0640".html_safe,
        navigation_class: Navigation::StateFileNcQuestionNavigation,
        pay_taxes_link: "https://www.nc.gov/working/taxes",
        return_type: "FormNCD400",
        schema_file_name: "NCIndividual2023v1.0.zip",
        state_name: "North Carolina",
        submission_builder_class: SubmissionBuilder::Ty2024::States::Nc::NcReturnXml,
        survey_link: "",
        tax_payment_info_url: "",
        tax_payment_url: "",
        tax_refund_url: "https://eservices.dor.nc.gov/wheresmyrefund/SelectionServlet",
        timezone: 'America/New_York',
        vita_link: "",
        voucher_form_name: "Form D-400V",
        voucher_path: "/pdfs/d400v-TY2023.pdf",
      },
      nj: {
        intake_class: StateFileNjIntake,
        calculator_class: Efile::Nj::Nj1040Calculator,
        filing_years: [2024],
        navigation_class: Navigation::StateFileNjQuestionNavigation,
        submission_builder_class: SubmissionBuilder::Ty2024::States::Nj::NjReturnXml,
        state_name: "New Jersey",
        return_type: "Resident",
        schema_file_name: "NJIndividual2023V0.4.zip",
        mail_voucher_address: "New Jersey Personal Income Tax<br/>" \
                              "Processing Center<br/>" \
                              "Trenton, NJ".html_safe,
        pay_taxes_link: "https://www.nj.gov/treasury/taxation/payments-notices.shtml",
        survey_link: "",
        tax_payment_info_url: "https://www.nj.gov/treasury/taxation/payments-notices.shtml",
        tax_payment_url: "https://www.nj.gov/treasury/taxation/payments-notices.shtml",
        tax_refund_url: "https://www.tax.ny.gov/pit/file/refund.htm",
        timezone: 'America/New_York',
        vita_link: "",
        voucher_form_name: "NJ Voucher Form",
        voucher_path: "",
      },
      ny: {
        intake_class: StateFileNyIntake,
        calculator_class: Efile::Ny::It201,
        filing_years: [2023],
        mail_voucher_address: "NYS Personal Income Tax<br/>" \
                              "Processing Center<br/>" \
                              "Box 4124<br/>" \
                              "Binghamton, NY 13902-4124".html_safe,
        navigation_class: Navigation::StateFileNyQuestionNavigation,
        pay_taxes_link: "https://www.tax.ny.gov/pay/",
        return_type: "IT201",
        state_name: "New York",
        schema_file_name: "NYSIndividual2023V4.0.zip",
        submission_builder_class: SubmissionBuilder::Ty2022::States::Ny::NyReturnXml,
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu",
        tax_payment_info_url: "https://www.tax.ny.gov/pay/ind/pay-income-tax-online.htm",
        tax_payment_url: "Tax.NY.gov",
        tax_refund_url: "https://www.tax.ny.gov/pit/file/refund.htm",
        timezone: 'America/New_York',
        vita_link: "https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form",
        voucher_form_name: "Form IT-201-V",
        voucher_path: "/pdfs/it201v_1223.pdf",
      }
    }.with_indifferent_access)
  end
end
