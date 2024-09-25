module Efile
  module Md
    class Md502Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
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
