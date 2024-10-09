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
        set_line(:MD502_DEPENDENT_EXEMPTION_COUNT, :get_dependent_exemption_count)
        set_line(:MD502_DEPENDENT_EXEMPTION_AMOUNT, :calculate_dependent_exemption_amount)
        set_line(:MD502_EXEMPTION_AMOUNT, :calculate_exemption_amount)
        @md502b.calculate
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {}
      end

      private

      def get_dependent_exemption_count
        @md502b.calculate.fetch(:MD502B_LINE_3)
      end

      def calculate_dependent_exemption_amount
        income_ranges = if filing_status_single? || filing_status_mfs?
                          [
                            [0..100_000, 3200],
                            [100_001..125_000, 1600],
                            [125_001..150_000, 800],
                            [150_001..Float::INFINITY, 0]
                          ]
                        elsif filing_status_hoh? || filing_status_mfj? || filing_status_qw?
                          [
                            [0..100_000, 3200],
                            [100_001..125_000, 3200],
                            [125_001..150_000, 3200],
                            [150_001..175_000, 1600],
                            [175_001..200_000, 800],
                            [200_001..Float::INFINITY, 0]
                          ]
                        else
                          [[0..Float::INFINITY, 0]]
                        end

        income_range_index = income_ranges.find_index { |(range, _)| range.include?(@direct_file_data.fed_agi) }

        amount_per_child = income_ranges[income_range_index][1]

        amount_per_child * line_or_zero(:MD502_DEPENDENT_EXEMPTION_COUNT)
      end

      def calculate_exemption_amount
        line_or_zero(:MD502_DEPENDENT_EXEMPTION_AMOUNT)
      end
    end
  end
end
