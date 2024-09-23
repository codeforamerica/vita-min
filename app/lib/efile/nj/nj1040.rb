module Efile
  module Nj
    class Nj1040 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
        set_line(:NJ1040_LINE_6_SPOUSE, :line_6_spouse_checkbox)
        set_line(:NJ1040_LINE_6, :calculate_line_6)
        set_line(:NJ1040_LINE_7_SELF, :line_7_self_checkbox)
        set_line(:NJ1040_LINE_7_SPOUSE, :line_7_spouse_checkbox)
        set_line(:NJ1040_LINE_7, :calculate_line_7)
        set_line(:NJ1040_LINE_15, :calculate_line_15)
        @lines.transform_values(&:value)
      end

      def line_6_spouse_checkbox
        @intake.filing_status_mfj?
      end

      def calculate_line_6
        self_exemption = 1
        number_of_line_6_exemptions = self_exemption + number_of_true_checkboxes([line_6_spouse_checkbox])
        number_of_line_6_exemptions * 1_000
      end

      def line_7_self_checkbox
        is_over_65(@intake.primary_birth_date)
      end

      def line_7_spouse_checkbox
        return false unless @intake.spouse_birth_date.present?
        is_over_65(@intake.spouse_birth_date)
      end

      def calculate_line_7
        number_of_line_7_exemptions = number_of_true_checkboxes([line_7_self_checkbox, line_7_spouse_checkbox])
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

      private

      def calculate_line_15
        if @direct_file_data.w2s.empty?
          return -1
        end

        sum = 0
        @direct_file_data.w2s.each do |w2|
          state_wage = w2.node.at("W2StateLocalTaxGrp StateWagesAmt").text.to_f
          sum += state_wage
        end
        sum.round
      end

      def is_over_65(birth_date)
        over_65_birth_year = MultiTenantService.new(:statefile).current_tax_year - 65
        birth_date <= Date.new(over_65_birth_year, 12, 31)
      end

      def number_of_true_checkboxes(checkbox_array_for_line)
        checkbox_array_for_line.sum { |a| a == true ? 1 : 0 }
      end
    end
  end
end