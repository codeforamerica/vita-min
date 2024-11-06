module Efile
  module Id
    class Id39rCalculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(value_access_tracker:, lines:, intake:, year:)
        super(intake: intake, year: year)

        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_data = intake.direct_file_data
      end

      def calculate
        set_line(:ID39R_B_LINE_6, :calculate_line_b_6)
      end

      def calculate_line_b_6
        [
          @direct_file_data.total_qualifying_dependent_care_expenses,
          [12_000 - @direct_file_data.excluded_benefits_amount, 0].max,
          @direct_file_data.primary_earned_income_amount,
          @direct_file_data.spouse_earned_income_amount,
        ].min
      end
    end
  end
end
