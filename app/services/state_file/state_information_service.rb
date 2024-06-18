module StateFile
  class StateInformationService
    class << self
      def active_state_codes
        STATES_INFO.keys.map(&:to_s)
      end

      def download_form_name(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:download_form_name]
      end

      def mail_voucher_address(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:mail_voucher_address]
      end

      def pay_mail_online_link(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:pay_mail_online_link]
      end

      def pay_mail_online_text(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:pay_mail_online_text]
      end

      def refund_url(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:refund_url]
      end

      def state_name(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:name]
      end

      def state_code_to_name_map
        active_state_codes.to_h { |state_code, _| [state_code, state_name(state_code)] }
      end

      def state_code_from_intake_class(klass)
        state_code, _ = STATES_INFO.find do |_, state_info|
          state_info[:intake_class] == klass
        end
        state_code.to_s
      end

      def survey_link(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:survey_link]
      end

      def tax_payment_url(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:tax_payment_url]
      end

      def vita_link(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:vita_link]
      end

      def voucher_path(state_code)
        validate_state_code(state_code)
        STATES_INFO[state_code.to_sym][:voucher_path]
      end
    end

    private

    def self.validate_state_code(state_code)
      unless active_state_codes.include?(state_code)
        raise StandardError, "No state code '#{state_code}'"
      end
    end

    STATES_INFO = {
      az: {
        intake_class: StateFileAzIntake,
        name: "Arizona",
        refund_url: "https://aztaxes.gov/home/checkrefund",
        tax_payment_url: 'AZTaxes.gov',
        download_form_name: 'Form AZ-140V',
        mail_voucher_address: "Arizona Department of Revenue<br/>"\
          "PO Box 29085<br/>"\
          "Phoenix, AZ 85038-9085".html_safe,
        pay_mail_online_link: 'https://azdor.gov/making-payments-late-payments-and-filing-extensions',
        vita_link: 'https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form',
        voucher_path: '/pdfs/AZ-140V.pdf',
        survey_link: 'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey',
      },
      ny: {
        intake_class: StateFileNyIntake,
        name: "New York",
        refund_url: "https://www.tax.ny.gov/pit/file/refund.htm",
        tax_payment_url: 'Tax.NY.gov',
        download_form_name: 'Form IT-201-V',
        mail_voucher_address: "NYS Personal Income Tax<br/>"\
          "Processing Center<br/>"\
          "Box 4124<br/>"\
          "Binghamton, NY 13902-4124".html_safe,
        pay_mail_online_link: 'https://www.tax.ny.gov/pay/ind/pay-income-tax-online.htm',
        vita_link: 'https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form',
        voucher_path: '/pdfs/it201v_1223.pdf',
        survey_link: 'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu',
      }
    }
  end
end
