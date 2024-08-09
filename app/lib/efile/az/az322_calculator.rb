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
        @intake.az322_contributions.drop(3).sum(&:amount).round
      end

      def calculate_line_5
        @intake.az322_contributions.sum(&:amount).round
      end

      def calculate_line_11
        line_or_zero(:AZ322_LINE_5)
      end

      def calculate_line_12
        case @intake.filing_status.to_sym
        when :married_filing_jointly
          400
        else
          200
        end
      end

      def calculate_line_13
        [line_or_zero(:AZ322_LINE_11), line_or_zero(:AZ322_LINE_12)].min
      end

      def calculate_line_20
        line_or_zero(:AZ322_LINE_13)
      end

      def calculate_line_22
        line_or_zero(:AZ322_LINE_20)
      end
    end
  end
end
