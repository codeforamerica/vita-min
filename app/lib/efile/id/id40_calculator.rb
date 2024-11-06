module Efile
  module Id
    class Id40Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @id39r = Efile::Id::Id39RCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake,
        )
      end

      def calculate
        @id39r.calculate
        set_line(:ID40_LINE_6A, :calculate_line_6a)
        set_line(:ID40_LINE_6B, :calculate_line_6b)
        set_line(:ID40_LINE_6C, :calculate_line_6c)
        set_line(:ID40_LINE_6D, :calculate_line_6d)
        set_line(:ID40_LINE_29, :calculate_line_29)
        set_line(:ID40_LINE_46, :calculate_line_46)
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

      def calculate_line_6a
        @direct_file_data.claimed_as_dependent? ? 0 : 1
      end

      def calculate_line_6b
        (@intake.filing_status_mfj? && !@direct_file_data.spouse_is_a_dependent?) ? 1 : 0
      end

      def calculate_line_6c
        @intake.dependents.count
      end

      def calculate_line_6d
        line_or_zero(:ID40_LINE_6A) + line_or_zero(:ID40_LINE_6B) + line_or_zero(:ID40_LINE_6C)
      end

      def calculate_line_29
        if @intake.has_unpaid_sales_use_tax? && !@intake.total_purchase_amount.nil?
          (@intake.total_purchase_amount * 0.06).round
        else
          0
        end
      end

      def calculate_line_46
        @intake.state_file_w2s.sum { |item| item.state_income_tax_amount.round } +
          @intake.state_file1099_gs.sum { |item| item.state_income_tax_withheld_amount.round } +
          @intake.state_file1099_rs.sum { |item| item.state_tax_withheld_amount.round }
      end
    end
  end
end
