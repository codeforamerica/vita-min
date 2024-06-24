module StateFile
  module Ny
    module Efile
    class NysTaxRateSchedule
      # Implements the NYS Tax Rate Schedule, as documented in the IT-201 instructions
      # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#nys-tax-rate-schedule
      class << self
        def calculate(taxable_income, filing_status)
          rows = case filing_status
                 when :single, :married_filing_separately then single_filer_rows
                 when :married_filing_jointly, :qualifying_widow then joint_filer_rows
                 when :head_of_household then head_of_household_rows
                 end
          schedule_row = rows.reverse.find do |row|
            taxable_income > row.floor && (taxable_income <= row.ceiling)
          end
          schedule_row.compute(taxable_income)
        end

        def single_filer_rows
          [
            TaxRateScheduleRow.new(-Float::INFINITY, 8_500, 0, 0.04),
            TaxRateScheduleRow.new(8_500, 11_700, 340, 0.045),
            TaxRateScheduleRow.new(11_700, 13_900, 484, 0.0525),
            TaxRateScheduleRow.new(13_900, 80_650, 600, 0.055),
            TaxRateScheduleRow.new(80_650, 215_400, 4_271, 0.06),
            TaxRateScheduleRow.new(215_400, 1_077_550, 12_356, 0.0685),
            TaxRateScheduleRow.new(1_077_550, 5_000_000, 71_413, 0.0965),
            TaxRateScheduleRow.new(5_000_000, 25_000_000, 449_929, 0.103),
            TaxRateScheduleRow.new(25_000_000, Float::INFINITY, 2_509_929, 0.109)
          ]
        end

        def joint_filer_rows
          [
            TaxRateScheduleRow.new(-Float::INFINITY, 17_150, 0, 0.04),
            TaxRateScheduleRow.new(17_150, 23_600, 686, 0.045),
            TaxRateScheduleRow.new(23_600, 27_900, 976, 0.0525),
            TaxRateScheduleRow.new(27_900, 161_550, 1_202, 0.055),
            TaxRateScheduleRow.new(161_550, 323_200, 8_553, 0.06),
            TaxRateScheduleRow.new(323_200, 2_155_350, 18_252, 0.0685),
            TaxRateScheduleRow.new(2_155_350, 5_000_000, 143_754, 0.0965),
            TaxRateScheduleRow.new(5_000_000, 25_000_000, 418_263, 0.103),
            TaxRateScheduleRow.new(25_000_000, Float::INFINITY, 2_478_263, 0.109)
          ]
        end

        def head_of_household_rows
          [
            TaxRateScheduleRow.new(-Float::INFINITY, 12_800, 0, 0.04),
            TaxRateScheduleRow.new(12_800, 17_650, 512, 0.045),
            TaxRateScheduleRow.new(17_650, 20_900, 730, 0.0525),
            TaxRateScheduleRow.new(20_900, 107_650, 901, 0.055),
            TaxRateScheduleRow.new(107_650, 269_300, 5_672, 0.06),
            TaxRateScheduleRow.new(269_300, 1_616_450, 15_371, 0.0685),
            TaxRateScheduleRow.new(1_616_450, 5_000_000, 107_651, 0.0965),
            TaxRateScheduleRow.new(5_000_000, 25_000_000, 434_163, 0.103),
            TaxRateScheduleRow.new(25_000_000, Float::INFINITY, 2_494_163, 0.109)
          ]
        end
      end

      class TaxRateScheduleRow
        attr_reader :floor, :ceiling, :cumulative, :rate

        def initialize(floor, ceiling, cumulative, rate)
          @floor = floor
          @ceiling = ceiling
          @cumulative = cumulative
          @rate = rate
        end

        def compute(amount)
          if amount < 0
            raise "Negative income input"
          end
          amount_for_rate =
            if @floor == -Float::INFINITY
              amount
            else
              amount - @floor
            end
          @cumulative + (amount_for_rate * @rate)
        end
      end
    end
  end
end
