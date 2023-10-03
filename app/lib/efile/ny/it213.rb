module Efile
  module Ny
    class It213 < ::Efile::TaxCalculator
      attr_accessor :lines, :value_access_tracker

      def initialize(filing_status:, direct_file_data:, federal_dependent_child_count:, federal_dependent_child_count_between_4_and_17:)
        @filing_status = filing_status
        @direct_file_data = direct_file_data
        @federal_dependent_child_count = federal_dependent_child_count
        @federal_dependent_child_count_between_4_and_17 = federal_dependent_child_count_between_4_and_17
      end

      def calculate
        # TODO: Do we need to consider Worksheet B?
        # TODO: Only calculate Worksheet A if yes on line 2? Should only happen if they clicked the wrong federal button?
        # TODO: Only run calculate if yes in line 1, and 3
        set_line(:IT213_AMT_3, :calculate_line_3)
        set_line(:IT213_AMT_4, -> { @federal_dependent_child_count})
        set_line(:IT213_AMT_5, -> { @federal_dependent_child_count_between_4_and_17})
        set_line(:IT213_WORKSHEET_A_LINE_1, :calculate_worksheet_a_line_1)
        set_line(:IT213_WORKSHEET_A_LINE_2, :calculate_worksheet_a_line_2)
        set_line(:IT213_WORKSHEET_A_LINE_3, :calculate_worksheet_a_line_3)
        set_line(:IT213_WORKSHEET_A_LINE_4, :calculate_worksheet_a_line_4)
        set_line(:IT213_WORKSHEET_A_LINE_5, :calculate_worksheet_a_line_5)
        set_line(:IT213_WORKSHEET_A_LINE_6, :calculate_worksheet_a_line_6)
        if @lines[:IT213_WORKSHEET_A_LINE_6].value > 0
          set_line(:IT213_WORKSHEET_A_LINE_7, :calculate_worksheet_a_line_7)
          # Worksheet A, line 8 implementation depends on assumption that NYS 19 == 19A
          set_line(:IT213_WORKSHEET_A_LINE_8, :calculate_worksheet_a_line_8)
          set_line(:IT213_WORKSHEET_A_LINE_9, :calculate_worksheet_a_line_9)
          set_line(:IT213_WORKSHEET_A_LINE_10, :calculate_worksheet_a_line_10)
          set_line(:IT213_AMT_6, -> { @lines[:IT213_WORKSHEET_A_LINE_10].value })
          set_line(:IT213_AMT_7, -> { 0 }) # TODO revisit if worksheet C
        else
          # TODO: When rest of worksheet A is done, revisit
          set_line(:IT213_AMT_6, -> { 0 })
          set_line(:IT213_AMT_7, -> { 0 })
        end

        set_line(:IT213_AMT_8, :calculate_line_8)
        if @lines[:IT213_AMT_8].value > 0
          set_line(:IT213_AMT_9, :calculate_line_9)
          set_line(:IT213_AMT_10, :calculate_line_10)
          set_line(:IT213_AMT_11, :calculate_line_11)
          set_line(:IT213_AMT_12, :calculate_line_12)
          set_line(:IT213_AMT_13, :calculate_line_13)
          if @lines[:IT213_AMT_3].value == true
            set_line(:IT213_AMT_14, :calculate_line_14)
            set_line(:IT213_AMT_15, :calculate_line_15)
            set_line(:IT213_AMT_16, :calculate_line_16)
          else
            set_line(:IT213_AMT_16, -> { @lines[:IT213_AMT_13].value })
          end
          # TODO: if spouse filing separate line 17 and 18
        else
          set_line(:IT213_AMT_13, -> { 0 })
          set_line(:IT213_AMT_14, :calculate_line_14)
          set_line(:IT213_AMT_15, :calculate_line_15)
          set_line(:IT213_AMT_16, :calculate_line_16)
        end
      end

      private

      def calculate_line_3
        @lines[:AMT_19A].value <= cutoff_for_filing_status
      end

      def calculate_worksheet_a_line_1
        @federal_dependent_child_count * 1000
      end

      def calculate_worksheet_a_line_2
        @lines[:AMT_19A].value
      end

      def calculate_worksheet_a_line_3
        cutoff_for_filing_status
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
        @direct_file_data.fed_tax
      end

      def calculate_worksheet_a_line_8
        0 # TODO: check if we always set schedule 3 credits to 0
      end

      def calculate_worksheet_a_line_9
        @lines[:IT213_WORKSHEET_A_LINE_7].value #TODO: revisit if line 8 changes, revisit worksheet c
      end

      def calculate_worksheet_a_line_10
        [@lines[:IT213_WORKSHEET_A_LINE_6].value, @lines[:IT213_WORKSHEET_A_LINE_9].value].min # TODO: revisit worksheet c if line 6 is smaller than 9
      end

      def calculate_line_8
        @lines[:IT213_AMT_6].value + @lines[:IT213_AMT_7].value
      end

      def calculate_line_9
        @lines[:IT213_AMT_4].value
      end

      def calculate_line_10
        @lines[:IT213_AMT_8].value / @lines[:IT213_AMT_9].value
      end

      def calculate_line_11
        @lines[:IT213_AMT_5].value
      end

      def calculate_line_12
        @lines[:IT213_AMT_10].value * @lines[:IT213_AMT_11].value
      end

      def calculate_line_13
        (@lines[:IT213_AMT_12].value * 0.33).round
      end

      def calculate_line_14
        @lines[:IT213_AMT_5].value
      end

      def calculate_line_15
        @lines[:IT213_AMT_14].value * 100
      end

      def calculate_line_16
        [@lines[:IT213_AMT_13].value, @lines[:IT213_AMT_15].value].max
      end

      def cutoff_for_filing_status
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
    end
  end
end
