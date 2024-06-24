module StateFile
  class StateInformationService
    class << self
      [
        :intake_class,
        :mail_voucher_address,
        :primary_tax_form_name,
        :state_name,
        :survey_link,
        :tax_payment_info_url,
        :tax_payment_url,
        :tax_refund_url,
        :vita_link,
        :voucher_path,
      ].each do |attribute|
        define_method(attribute) do |state_code|
          raise StandardError, "No state code '#{state_code}'" if !active_state_codes.include?(state_code)

          STATES_INFO[state_code][attribute]
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

      def intake_class_from_state_code(state_code)
        STATES_INFO[state_code][:intake_class]
      end

      def intake_class_names
        intake_classes.map(&:name)
      end

      def submission_builder_from_intake_class(klass)
        state_info = STATES_INFO.values.find { |s| s[:intake_class] == klass }
        state_info[:submission_builder] if state_info.present?
      end
    end

    private

    STATES_INFO = IceNine.deep_freeze!({
      az: {
        intake_class: StateFileAzIntake,
        mail_voucher_address: "Arizona Department of Revenue<br/>" \
                              "PO Box 29085<br/>" \
                              "Phoenix, AZ 85038-9085".html_safe,
        primary_tax_form_name: "Form AZ-140V",
        state_name: "Arizona",
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey",
        tax_payment_info_url: "https://azdor.gov/making-payments-late-payments-and-filing-extensions",
        tax_payment_url: "AZTaxes.gov",
        tax_refund_url: "https://aztaxes.gov/home/checkrefund",
        vita_link: "https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form",
        voucher_path: "/pdfs/AZ-140V.pdf",
      },
      ny: {
        intake_class: StateFileNyIntake,
        mail_voucher_address: "NYS Personal Income Tax<br/>" \
                              "Processing Center<br/>" \
                              "Box 4124<br/>" \
                              "Binghamton, NY 13902-4124".html_safe,
        primary_tax_form_name: "Form IT-201-V",
        state_name: "New York",
        survey_link: "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu",
        tax_payment_info_url: "https://www.tax.ny.gov/pay/ind/pay-income-tax-online.htm",
        tax_payment_url: "Tax.NY.gov",
        tax_refund_url: "https://www.tax.ny.gov/pit/file/refund.htm",
        vita_link: "https://airtable.com/appQS3abRZGjT8wII/pagtpLaX0wokBqnuA/form",
        voucher_path: "/pdfs/it201v_1223.pdf",
      }
    }).with_indifferent_access
  end
end
