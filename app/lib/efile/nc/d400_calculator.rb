module Efile
  module Nc
    class D400Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @d400_schedule_s = Efile::Nc::D400ScheduleSCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end


      def calculate
        @d400_schedule_s.calculate
        set_line(:NCD400_LINE_9, :calculate_line_9)
        set_line(:NCD400_LINE_20A, :calculate_line_20a)
        set_line(:NCD400_LINE_20B, :calculate_line_20b)
        set_line(:NCD400_LINE_23, :calculate_line_23)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0 # placeholder
      end

      private

      def calculate_line_9
        line_or_zero(:NCD400_S_LINE_41)
      end

      def calculate_line_20a
        @direct_file_data.w2s.reduce(0) do |sum, w2|
          if w2.EmployeeSSN == @direct_file_data.primary_ssn
            sum += w2.StateIncomeTaxAmt
          end
          sum
        end
      end

      def calculate_line_20b
        @direct_file_data.w2s.reduce(0) do |sum, w2|
          if w2.EmployeeSSN == @direct_file_data.spouse_ssn
            sum += w2.StateIncomeTaxAmt
          end
          sum
        end
      end

      def calculate_line_23
        # sum of lines 20a through 22
        # 21a, 21c, 21d, and 22 are all blank
        # 21b is blank unless DF decides to support
        line_or_zero(:NCD400_LINE_20A) + line_or_zero(:NCD400_LINE_20B)
      end
    end
  end
end
