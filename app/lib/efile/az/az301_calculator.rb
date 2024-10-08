module Efile
  module Az
    class Az301Calculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
      end

      def calculate
        set_line(:AZ301_LINE_6a, method(:calculate_line_6a))
        set_line(:AZ301_LINE_6c, method(:calculate_line_6c))
        set_line(:AZ301_LINE_7a, method(:calculate_line_7a))
        set_line(:AZ301_LINE_7c, method(:calculate_line_7c))
        set_line(:AZ301_LINE_26, method(:calculate_line_26))
        set_line(:AZ301_LINE_27, method(:calculate_line_27))
        set_line(:AZ301_LINE_32, method(:calculate_line_32))
        set_line(:AZ301_LINE_33, method(:calculate_line_33))
        set_line(:AZ301_LINE_34, method(:calculate_line_34))
        set_line(:AZ301_LINE_40, method(:calculate_line_40))
        set_line(:AZ301_LINE_41, method(:calculate_line_41))
        set_line(:AZ301_LINE_60, method(:calculate_line_60))
        set_line(:AZ301_LINE_62, method(:calculate_line_62))
      end

      private

      def calculate_line_6a
        @lines[:AZ321_LINE_20]&.value
      end

      def calculate_line_6c
        @lines[:AZ321_LINE_22]&.value
      end

      def calculate_line_7a
        @lines[:AZ322_LINE_20]&.value
      end

      def calculate_line_7c
        @lines[:AZ322_LINE_22]&.value
      end

      def calculate_line_26
        (1..24).sum { |line_num| line_or_zero("AZ301_LINE_#{line_num}c") }
      end

      def calculate_line_27
        @lines[:AZ140_LINE_46]&.value
      end

      def calculate_line_32 # Add lines 27 and 31 (31 not in scope)
        @lines[:AZ301_LINE_27]&.value
      end

      def calculate_line_33
        line_or_zero(:AZ140_LINE_50) + line_or_zero(:AZ140_LINE_49)
      end

      def calculate_line_34
        [line_or_zero(:AZ301_LINE_32) - line_or_zero(:AZ301_LINE_33), 0].max
      end

      def calculate_line_40
        @lines[:AZ301_LINE_6c]&.value
      end

      def calculate_line_41
        @lines[:AZ301_LINE_7c]&.value
      end

      def calculate_line_60
        (35..58).sum { |line_num| line_or_zero("AZ301_LINE_#{line_num}") }
      end

      def calculate_line_62
        @lines[:AZ301_LINE_60]&.value
      end
    end
  end
end