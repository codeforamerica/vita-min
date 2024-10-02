module Efile
  module Nj
    class Nj1040 < ::Efile::TaxCalculator
      attr_reader :lines

      RENT_CONVERSION = 0.18

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
        set_line(:NJ1040_LINE_6_SPOUSE, :line_6_spouse_checkbox)
        set_line(:NJ1040_LINE_6, :calculate_line_6)
        set_line(:NJ1040_LINE_7_SELF, :line_7_self_checkbox)
        set_line(:NJ1040_LINE_7_SPOUSE, :line_7_spouse_checkbox)
        set_line(:NJ1040_LINE_7, :calculate_line_7)
        set_line(:NJ1040_LINE_8, :calculate_line_8)
        set_line(:NJ1040_LINE_13, :calculate_line_13)
        set_line(:NJ1040_LINE_15, :calculate_line_15)
        set_line(:NJ1040_LINE_27, :calculate_line_27)
        set_line(:NJ1040_LINE_29, :calculate_line_29)
        set_line(:NJ1040_LINE_38, :calculate_line_38)
        set_line(:NJ1040_LINE_39, :calculate_line_39)
        set_line(:NJ1040_LINE_40A, :calculate_line_40a)
        set_line(:NJ1040_LINE_42, :calculate_line_42)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {
        }
      end

      private
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
        number_of_line_7_exemptions = number_of_true_checkboxes([line_7_self_checkbox,
                                                                 line_7_spouse_checkbox])
        number_of_line_7_exemptions * 1_000
      end

      def calculate_line_8
        number_of_line_8_exemptions = number_of_true_checkboxes([@direct_file_data.is_primary_blind?,
                                                                 @direct_file_data.is_spouse_blind?])
        number_of_line_8_exemptions * 1_000
      end

      def calculate_line_40a
        is_mfs = @intake.filing_status == :married_filing_separately

        case @intake.household_rent_own
        when "own"
          property_tax_paid = @intake.property_tax_paid
        when "rent"
          property_tax_paid = @intake.rent_paid * RENT_CONVERSION
        else
          return nil
        end

        is_mfs ? (property_tax_paid / 2.0).round : property_tax_paid.round
      end

      def calculate_line_13
        line_or_zero(:NJ1040_LINE_6) +  line_or_zero(:NJ1040_LINE_7) +  line_or_zero(:NJ1040_LINE_8) 
      end

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

      def calculate_line_27
        calculate_line_15
      end

      def calculate_line_29
        calculate_line_27
      end

      def calculate_line_38
        calculate_line_13
      end

      def calculate_line_39
        calculate_line_29 - calculate_line_38
      end

      def calculate_line_42
        calculate_line_39
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
