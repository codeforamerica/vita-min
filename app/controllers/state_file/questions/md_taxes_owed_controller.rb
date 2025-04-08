module StateFile
  module Questions
    class MdTaxesOwedController < TaxesOwedController
      def self.form_key
        "state_file/taxes_owed_form"
      end

      def edit
        super
        @after_filing_deadline = app_time.in_time_zone(timezone).to_date.after?(md_submission_deadline)
      end

      private

      def md_payment_deadline
        @md_payment_deadline ||= StateFile::StateInformationService.payment_deadline_date("md", filing_year: current_year)
      end

      def md_submission_deadline
        @md_submission_deadline ||= Date.new(current_year, 4, 15).in_time_zone(timezone).at_midnight
      end

      def current_year
        current_tax_year + 1
      end

      def current_tax_year
        MultiTenantService.new(:statefile).current_tax_year
      end

      def timezone
        StateFile::StateInformationService.timezone(current_intake.state_code)
      end
    end
  end
end
