module Efile
  module Ny
    class It213 < ::Efile::TaxCalculator
      attr_accessor :lines, :value_access_tracker

      def initialize(filing_status:, federal_dependent_child_count:, under_4_federal_dependent_child_count:, federal_tax:)
        @filing_status = filing_status
        @federal_dependent_child_count = federal_dependent_child_count
        @under_4_federal_dependent_child_count = under_4_federal_dependent_child_count
        @federal_tax = federal_tax
      end

      def calculate
        # TODO: Do we need to consider Worksheet B?
        # TODO: Only calculate Worksheet A if yes on line 2? Should only happen if they clicked the wrong federal button?
        # TODO: Only run calculate if yes in line 1, and 3
        set_line(:IT213_WORKSHEET_A_LINE_1, :calculate_worksheet_a_line_1)
        set_line(:IT213_WORKSHEET_A_LINE_2, :calculate_worksheet_a_line_2)
        set_line(:IT213_WORKSHEET_A_LINE_3, :calculate_worksheet_a_line_3)
        set_line(:IT213_WORKSHEET_A_LINE_4, :calculate_worksheet_a_line_4)
        set_line(:IT213_WORKSHEET_A_LINE_5, :calculate_worksheet_a_line_5)
        set_line(:IT213_WORKSHEET_A_LINE_6, :calculate_worksheet_a_line_6)
        if @lines[:IT213_WORKSHEET_A_LINE_6].value > 0
          set_line(:IT213_WORKSHEET_A_LINE_7, :calculate_worksheet_a_line_7)

          # todo: the rest of the owl worksheet
        else
          # TODO: When rest of worksheet A is done, revisit
          set_line(:IT213_AMT_6, -> { 0 })
          set_line(:IT213_AMT_7, -> { 0 })
        end
        set_line(:IT213_AMT_16, -> { 0 })
      end

      private

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
          subtotal.ceil(-3) # Round up to next 1000
        end
      end

      def calculate_worksheet_a_line_5
        line_or_zero(:IT213_WORKSHEET_A_LINE_4) * 0.05
      end

      def calculate_worksheet_a_line_6
        [@lines[:IT213_WORKSHEET_A_LINE_1].value - @lines[:IT213_WORKSHEET_A_LINE_5].value, 0].max
      end

      def calculate_worksheet_a_line_7
        @federal_tax
      end
    end
  end
end
