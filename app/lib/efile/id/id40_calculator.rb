module Efile
  module Id
    class Id40Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @id39r = Efile::Id::Id39rCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake,
          year: year,
        )
      end

      def calculate
        @id39r.calculate
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {}
      end

      private

      # line calculation methods go here
    end
  end
end
