module Efile
  module Md
    class Md502Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @md502b = Efile::Md::Md502bCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end

      def calculate
        set_line(:MD502_LINE_1, @direct_file_data, :fed_agi)
        set_line(:MD502_LINE_1A, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:MD502_LINE_1B, @direct_file_data, :fed_wages_salaries_tips)
        set_line(:MD502_LINE_1D, @direct_file_data, :fed_taxable_pensions)
        set_line(:MD502_LINE_1E, :calculate_line_1e)
        set_line(:MD502_LINE_A_YOURSELF, :calculate_line_a_yourself)
        set_line(:MD502_LINE_A_SPOUSE, :calculate_line_a_spouse)
        set_line(:MD502_LINE_A_CHECKED_COUNT, :calculate_line_a_checked_count)
        set_line(:MD502_LINE_A_AMOUNT, :calculate_line_a_amount)
        @md502b.calculate
        set_line(:MD502_DEPENDENT_EXEMPTION_COUNT, :get_dependent_exemption_count)
        set_line(:MD502_DEPENDENT_EXEMPTION_AMOUNT, :calculate_total_dependent_exemption_amount)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {}
      end

      private

      def calculate_line_1e
        total_interest = @direct_file_data.fed_taxable_income + @direct_file_data.fed_tax_exempt_interest
        total_interest > 11_600
      end

      def calculate_line_a_yourself
        # should we use filing_status_dependent? instead
        @direct_file_data.claimed_as_dependent? ? nil : "X"
      end

      def calculate_line_a_spouse
        filing_status_mfj? ? "X" : nil
      end

      def calculate_line_a_checked_count
        count = 0
        count += 1 if @lines[:MD502_LINE_A_YOURSELF].value.present?
        count += 1 if @lines[:MD502_LINE_A_SPOUSE].value.present?
        count
      end

      def calculate_line_a_amount
        # Exemption amount
        income_ranges = if filing_status_single? || filing_status_mfs?
                          [
                            [-Float::INFINITY..100_000, 3200],
                            [100_001..125_000, 1600],
                            [125_001..150_000, 800],
                            [150_001..Float::INFINITY, 0]
                          ]
                        elsif filing_status_hoh? || filing_status_mfj? || filing_status_qw?
                          [
                            [-Float::INFINITY..100_000, 3200],
                            [100_001..125_000, 3200],
                            [125_001..150_000, 3200],
                            [150_001..175_000, 1600],
                            [175_001..200_000, 800],
                            [200_001..Float::INFINITY, 0]
                          ]
                        else
                          [[-Float::INFINITY..Float::INFINITY, 0]]
                        end

        income_range_index = income_ranges.find_index { |(range, _)| range.include?(@direct_file_data.fed_agi) }

        income_ranges[income_range_index][1]
      end

      def get_dependent_exemption_count
        line_or_zero(:MD502B_LINE_3)
      end

      def calculate_total_dependent_exemption_amount
        line_or_zero(:MD502_LINE_A_AMOUNT) * line_or_zero(:MD502_DEPENDENT_EXEMPTION_COUNT)
      end

      def filing_status_dependent?
        @filing_status == :dependent
      end
    end
  end
end
