module Efile
  module Nj
    class Nj1040 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
        set_line(:NJ1040_LINE_6_SPOUSE, :calculate_line_6_spouse_checkbox)
        set_line(:NJ1040_LINE_6, :calculate_line_6)
        set_line(:NJ1040_LINE_7_SELF, :calculate_line_7_self_checkbox)
        set_line(:NJ1040_LINE_7_SPOUSE, :calculate_line_7_spouse_checkbox)
        set_line(:NJ1040_LINE_7, :calculate_line_7)
        @lines.transform_values(&:value)
      end

      def calculate_line_6_spouse_checkbox
        @intake.filing_status_mfj?
      end

      def calculate_line_6
        number_of_line_6_exemptions = 1 # defaults to 1 since self checkbox is always true
        if calculate_line_6_spouse_checkbox
          number_of_line_6_exemptions += 1
        end
        # DF data does not contain Domestic Partner information, so we are not supporting the Domestic Partner exemption
        number_of_line_6_exemptions * 1_000
      end

      def calculate_line_7_self_checkbox
        over_65_birth_year = MultiTenantService.new(:statefile).current_tax_year - 65
        return true if @intake.primary_birth_date <= Date.new(over_65_birth_year, 12, 31)
        false
      end

      def calculate_line_7_spouse_checkbox
        over_65_birth_year = MultiTenantService.new(:statefile).current_tax_year - 65
        return false unless @intake.spouse_birth_date.present?
        return true if @intake.spouse_birth_date <= Date.new(over_65_birth_year, 12, 31)
        false
      end

      def calculate_line_7
        number_of_line_7_exemptions = 0
        if calculate_line_7_self_checkbox
          number_of_line_7_exemptions += 1
        end
        if calculate_line_7_spouse_checkbox
          number_of_line_7_exemptions += 1
        end
        number_of_line_7_exemptions * 1_000
      end

      def total_exemption_amount
        0
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {
        }
      end
    end
  end
end