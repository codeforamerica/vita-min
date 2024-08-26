module Efile
  module Nj
    class Nj1040 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super

        # @eligibility_lived_in_state = intake.eligibility_lived_in_state
      end

      def calculate
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {
        }
      end
    end
  end
end