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
        set_line(:AZ301_LINE_6a, -> { @lines[:AZ321_LINE_20]&.value })
        set_line(:AZ301_LINE_6c, -> { @lines[:AZ321_LINE_22]&.value })
        set_line(:AZ301_LINE_7a, -> { @lines[:AZ322_LINE_20]&.value })
        set_line(:AZ301_LINE_7c, -> { @lines[:AZ322_LINE_22]&.value })
        set_line(:AZ301_LINE_26, :calculate_line_26)
        set_line(:AZ301_LINE_27, -> { @lines[:AZ140_LINE_46]&.value })
        set_line(:AZ301_LINE_33, :calculate_line_33)
        set_line(:AZ301_LINE_34, -> { 0 }) # Subtract line 33 from line 32 (not in scope). Enter the difference. If less than zero, enter “0”
        set_line(:AZ301_LINE_40, -> { @lines[:AZ301_LINE_6c]&.value })
        set_line(:AZ301_LINE_41, -> { @lines[:AZ301_LINE_7c]&.value })
        set_line(:AZ301_LINE_60, :calculate_line_60 )
        set_line(:AZ301_LINE_62,  -> { @lines[:AZ301_LINE_60]&.value }) #Add lines 60 and 61 (not in scope).
      end

      private

      def calculate_line_26
        result = 0
        (1..24).each do |line_num|
          result += line_or_zero("AZ301_LINE_#{line_num}c")
        end

        result
      end

      def calculate_line_33
        line_or_zero(:AZ140_LINE_50) + line_or_zero(:AZ140_LINE_49)
      end

      def calculate_line_60
        # Add 35 through 58
        result = 0
        (35..58).each do |line_num|
          result += line_or_zero("AZ301_LINE_#{line_num}")
        end

        result
      end
    end
  end
end
