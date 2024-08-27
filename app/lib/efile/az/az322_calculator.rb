module Efile
  module Az
    class Az322Calculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
      end

      def calculate
        set_line(:AZ322_LINE_4, :calculate_line_4)
        set_line(:AZ322_LINE_5, :calculate_line_5)
        set_line(:AZ322_LINE_11, :calculate_line_11)
        set_line(:AZ322_LINE_12, :calculate_line_12)
        set_line(:AZ322_LINE_13, :calculate_line_13)
        set_line(:AZ322_LINE_20, :calculate_line_20)
        set_line(:AZ322_LINE_22, :calculate_line_22)
      end

      private

      def calculate_line_4
        # 2023 Instructions: If you made contributions or paid fees to more than three public schools, enter the amount from line 4h of the continuation sheet
        @intake.az322_contributions.drop(3).sum(&:amount).round
      end

      def calculate_line_5
        # Total contributions made or fees paid to public schools during 2023
        @intake.az322_contributions.sum(&:amount).round
      end

      def calculate_line_11
        # Add lines 5 and 10 (line 10 not in scope)
        line_or_zero(:AZ322_LINE_5)
      end

      def calculate_line_12
        # Single taxpayers or heads of household, enter $200. MFJ taxpayers, enter $400
        case @intake.filing_status.to_sym
        when :married_filing_jointly
          400
        else
          200
        end
      end

      def calculate_line_13
        # Total current year's credit: Enter the smaller of line 11 or 12.
        [line_or_zero(:AZ322_LINE_11), line_or_zero(:AZ322_LINE_12)].min
      end

      def calculate_line_20
        # Current year's credit (enter the amount from line 13)
        line_or_zero(:AZ322_LINE_13)
      end

      def calculate_line_22
        # Total available credit (add lines 20 and line 21 (line 21 not in scope))
        line_or_zero(:AZ322_LINE_20)
      end
    end
  end
end
