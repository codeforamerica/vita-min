module Efile
  module Md
    class Md502SuCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD502_SU_LINE_1, :calculate_line_1)
        set_line(:MD502_SU_LINE_AB, :calculate_line_ab)
      end

      private

      def calculate_line_1
        calculate_line_ab
      end

      def calculate_line_ab
        @direct_file_json_data.interest_reports.sum(&:interest_on_government_bonds).round
      end
    end
  end
end
