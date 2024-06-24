module StateFile
  module Ny
    module Efile
      class NycEicRateWorksheet < ::Efile::TaxCalculator
        # https://www.tax.ny.gov/forms/current-forms/it/it215i.htm#nyc-eic-worksheet

        attr_accessor :lines, :value_access_tracker

        def initialize(value_access_tracker:, lines:)
          @value_access_tracker = value_access_tracker
          @lines = lines
        end

        def calculate
          set_line(:NYC_EIC_RATE_WK_LINE_1, -> { @lines[:IT201_LINE_33].value })
          @rate_table_row = NycEicRateTable.find_row(@lines[:NYC_EIC_RATE_WK_LINE_1].value)
          if @rate_table_row.line_2_amt.present?
            set_line(:NYC_EIC_RATE_WK_LINE_2, -> { @rate_table_row.line_2_amt })
            set_line(:NYC_EIC_RATE_WK_LINE_3, :calculate_line_3)
            set_line(:NYC_EIC_RATE_WK_LINE_4, :calculate_line_4)
            set_line(:NYC_EIC_RATE_WK_LINE_5, -> { @rate_table_row.line_5_amt })
            set_line(:NYC_EIC_RATE_WK_LINE_6, :calculate_line_6)
          else
            set_line(:NYC_EIC_RATE_WK_LINE_6, -> { @rate_table_row.line_6_amt })
          end
        end

        private

        def calculate_line_3
          @lines[:NYC_EIC_RATE_WK_LINE_1].value - @lines[:NYC_EIC_RATE_WK_LINE_2].value
        end

        def calculate_line_4
          (@lines[:NYC_EIC_RATE_WK_LINE_3].value * 0.00002).round(4)
        end

        def calculate_line_6
          @lines[:NYC_EIC_RATE_WK_LINE_5].value - @lines[:NYC_EIC_RATE_WK_LINE_4].value
        end
      end
    end
  end
end
