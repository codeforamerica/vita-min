module Efile
  module Wa
    class Wa1000 < ::Efile::TaxCalculator # TODO: rename child class to something ending in 'Calculator'?
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        @year = year
        @intake = intake
        # single, mfj, mfs & hoh are the ones we support for now; qualifying_widow is not supprted in AZ140
        @filing_status = intake.filing_status.to_sym
        @direct_file_data = intake.direct_file_data
        # intake.state_file_w2s.each do |w2|
        #   dest_w2 = @direct_file_data.w2s[w2.w2_index]
        #   dest_w2.node.at("W2StateLocalTaxGrp").inner_html = w2.state_tax_group_xml_node
        # end
        @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
        @lines = HashWithIndifferentAccess.new
      end

      def calculate
        set_line(:WA100_LINE_1, :calculate_line_1)
        set_line(:WA100_LINE_2, :calculate_line_2)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        calculate_line_1 - calculate_line_2
      end

      private

      def calculate_line_1
        1000000
      end

      def calculate_line_2
        0
      end
    end
  end
end
