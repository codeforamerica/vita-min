module Efile
  module Md
    class Md502RCalculator < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD502R_LINE_9A, :calculate_line_9a)
        set_line(:MD502R_LINE_9B, :calculate_line_9b)
      end

      private

      def calculate_line_9a
        if @intake.direct_file_data.fed_ssb.positive?
          if @intake.filing_status_mfj?
            @intake.primary_ssb_amount&.round || 0
          else
            @intake.direct_file_data.fed_ssb.round
          end
        end
      end

      def calculate_line_9b
        if @intake.filing_status_mfj? && @intake.direct_file_data.fed_ssb.positive? && @intake.spouse_ssb_amount.present?
          @intake.spouse_ssb_amount.round
        end
      end
    end
  end
end
