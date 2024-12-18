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
        set_line(:AZ301_LINE_25, method(:calculate_line_25))
        set_line(:AZ301_LINE_26, method(:calculate_line_26))
        set_line(:AZ301_LINE_31, method(:calculate_line_31))
        set_line(:AZ301_LINE_32, method(:calculate_line_32))
        set_line(:AZ301_LINE_33, method(:calculate_line_33))
        set_line(:AZ301_LINE_39, method(:calculate_line_39))
        set_line(:AZ301_LINE_40, method(:calculate_line_40))
        set_line(:AZ301_LINE_58, method(:calculate_line_58))
        set_line(:AZ301_LINE_60, method(:calculate_line_60))
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

      def calculate_line_25
        (1..23).sum { |line_num| line_or_zero("AZ301_LINE_#{line_num}c") }
      end

      def calculate_line_26
        @lines[:AZ140_LINE_46]&.value
      end

      def calculate_line_31 # Add lines 26 and 30 (30 not in scope)
        @lines[:AZ301_LINE_26]&.value
      end

      def calculate_line_32
        line_or_zero(:AZ140_LINE_50) + line_or_zero(:AZ140_LINE_49)
      end

      def calculate_line_33
        [line_or_zero(:AZ301_LINE_31) - line_or_zero(:AZ301_LINE_32), 0].max
      end

      def calculate_line_39
        [line_or_zero(:AZ301_LINE_6c), line_or_zero(:AZ301_LINE_33)].min
      end

      def calculate_line_40
        subtraction = [line_or_zero(:AZ301_LINE_33) - line_or_zero(:AZ301_LINE_39), 0].max
        [subtraction, line_or_zero(:AZ301_LINE_7c)].min
      end

      def calculate_line_58
        (34..56).sum { |line_num| line_or_zero("AZ301_LINE_#{line_num}") }
      end

      def calculate_line_60
        @lines[:AZ301_LINE_58]&.value
      end
    end
  end
end