module Efile
  module Ny
    class It213 < ::Efile::TaxCalculator
      attr_accessor :lines, :value_access_tracker

      def initialize(filing_status:, federal_dependent_child_count:, under_4_federal_dependent_child_count:)
        @filing_status = filing_status
        @federal_dependent_child_count = federal_dependent_child_count
        @under_4_federal_dependent_child_count = under_4_federal_dependent_child_count
      end

      def calculate
        # TODO: Do we need to consider Worksheet B?
        # TODO: Only calculate Worksheet A if yes on line 2? Should only happen if they clicked the wrong federal button?
        # TODO: Only run calculate if yes in line 1, and 3
        # TODO: set_line wants to look for methods prefixed by IT213 hmm
        set_line(:WORKSHEET_A_LINE_1, :calculate_worksheet_a_line_1)
        set_line(:WORKSHEET_A_LINE_2, :calculate_worksheet_a_line_2)
        set_line(:WORKSHEET_A_LINE_3, :calculate_worksheet_a_line_3)
        set_line(:WORKSHEET_A_LINE_4, :calculate_worksheet_a_line_4)
        set_line(:WORKSHEET_A_LINE_5, :calculate_worksheet_a_line_5)
        set_line(:AMT_16, -> { 0 })
      end

      private

      def set_line(line_id, value_fn)
        super("IT213_#{line_id}", value_fn)
      end

      def calculate_worksheet_a_line_1
        @federal_dependent_child_count * 1000
      end

      def calculate_worksheet_a_line_2
        @lines[:AMT_19A].value
      end

      def calculate_worksheet_a_line_3
        case @filing_status
        when :married_filing_jointly
          111_000
        when :single, :head_of_household, :qualifying_surviving_spouse
          75_000
        when :married_filing_separately
          55_000
        else
          raise "Filing status not found..."
        end
      end

      def calculate_worksheet_a_line_4
        if @lines[:IT213_WORKSHEET_A_LINE_2].value > @lines[:IT213_WORKSHEET_A_LINE_3].value
          subtotal = @lines[:IT213_WORKSHEET_A_LINE_2].value - @lines[:IT213_WORKSHEET_A_LINE_3].value
          subtotal.ceil(-3) # Round up to nearest 1000
        else
          nil
        end
      end

      def calculate_worksheet_a_line_5
        if @lines[:IT213_WORKSHEET_A_LINE_4].value.nil?
          0
        else
          @lines[:IT213_WORKSHEET_A_LINE_4] * 0.05
        end
      end
    end
  end
end
