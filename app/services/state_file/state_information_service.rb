module StateFile
  class StateInformationService
    class << self
      [
        :download_form_name,
        :intake_class,
        :mail_voucher_address,
        :pay_mail_online_link,
        :refund_url,
        :state_name,
        :survey_link,
        :tax_payment_url,
        :vita_link,
        :voucher_path,
      ].each do |attribute|
        define_method(attribute) do |state_code|
          raise StandardError, "No state code '#{state_code}'" if !active_state_codes.include?(state_code)

          value = STATES_INFO[state_code.to_sym][attribute]
          raise StandardError, "State '#{state_code}' does not have '#{attribute}'" if !value
          value
        end
      end

      def active_state_codes
        STATES_INFO.keys.map(&:to_s)
      end

      def state_intake_classes
        STATES_INFO.map { |_, attrs| attrs[:intake_class] }
      end
      
      def state_intake_class_names
        state_intake_classes.map(&:to_s).freeze
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
    end

    private

    STATES_INFO = {
      az: {
        intake_class: StateFileAzIntake,
        state_name: "Arizona",
        refund_url: "https://aztaxes.gov/home/checkrefund",
        tax_payment_url: "AZTaxes.gov",
        download_form_name: "Form AZ-140V",
        mail_voucher_address: "Arizona Department of Revenue<br/>"\
          "PO Box 29085<br/>"\
          "Phoenix, AZ 85038-9085".html_safe,
        pay_mail_online_link: "https://azdor.gov/making-payments-late-payments-and-filing-extensions",
        vita_link: "https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form",
        voucher_path: "/pdfs/AZ-140V.pdf",
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey",
      },
      ny: {
        intake_class: StateFileNyIntake,
        state_name: "New York",
        refund_url: "https://www.tax.ny.gov/pit/file/refund.htm",
        tax_payment_url: "Tax.NY.gov",
        download_form_name: "Form IT-201-V",
        mail_voucher_address: "NYS Personal Income Tax<br/>"\
          "Processing Center<br/>"\
          "Box 4124<br/>"\
          "Binghamton, NY 13902-4124".html_safe,
        pay_mail_online_link: "https://www.tax.ny.gov/pay/ind/pay-income-tax-online.htm",
        vita_link: "https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form",
        voucher_path: "/pdfs/it201v_1223.pdf",
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu",
      }
    }
  end
end
