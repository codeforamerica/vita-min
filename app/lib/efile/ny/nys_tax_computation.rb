module Efile
  module Ny
    class NysTaxComputation
      # Implements the NYS Tax Computation, for use with NY AGI over $107,650, as documented in the IT-201 instructions
      # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#tax-computation
      # Worksheet numbers in the comments correspond to schedules in the instructions

      class << self
        def calculate(agi, taxable_income, filing_status)
          # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#tax-computation
          line1 = agi
          line2 = taxable_income
          adjuster = line_3_adjuster_for_filing_status(filing_status)
          line3 = line2 * adjuster
          if line1 >= 157_650
            line9 = line3
          else
            schedules = schedules_for_filing_status(filing_status)
            schedule = schedules.find { |w| w.valid_for(taxable_income) }
            line4 = schedule.compute(taxable_income)
            line5 = line3 - line4
            line6 = line1 - 107_650
            line7 = (line6 / 50_000.to_f).round(4) # Divide line 6 by $50,000 and round the result to the fourth decimal place
            line8 = line5 * line7
            line9 = line4 + line8
          end
          line9
        end

        #private

        def schedules_for_filing_status(filing_status)
          case filing_status
          when :married_filing_jointly, :qualifying_widow then joint_filer_schedules
          when :single, :married_filing_separately then single_filer_schedules
          when :head_of_household then head_of_household_schedules
          end
        end

        def line_3_adjuster_for_filing_status(filing_status)
          # Worksheet 1, 7, 12
          case filing_status
          when :married_filing_jointly, :qualifying_widow then 0.055
          when :single, :married_filing_separately then 0.06
          when :head_of_household then 0.06
          end
        end

        def joint_filer_schedules
          [
            Schedule.new(0, 17_150, 0, 0.04),
            Schedule.new(17_150, 23_600, 686, 0.045),
            Schedule.new(23_600, 27_900, 976, 0.0525),
            Schedule.new(27_900, 161_550, 1_202, 0.055),
            Schedule.new(161_550, 323_200, 8_553, 0.06),
            Schedule.new(323_200, 2_155_350, 18_252, 0.0685),
            Schedule.new(2_155_350, 5_000_000, 143_754, 0.0965),
            Schedule.new(5_000_000, 25_000_000, 418_263, 0.103),
            Schedule.new(25_000_000, Float::INFINITY, 2_478_263, 0.109),
          ]
        end

        def single_filer_schedules
          [
            Schedule.new(0, 8_500,  0, 0.04),
            Schedule.new(8_500, 11_700, 340, 0.045),
            Schedule.new(11_700, 13_900, 484, 0.0525),
            Schedule.new(13_900, 80_650, 600, 0.055),
            Schedule.new(80_650, 215_400, 4_271, 0.06),
            Schedule.new(215_400, 1_077_550, 12_356, 0.0685),
            Schedule.new(1_077_550, 5_000_000, 71_413, 0.0965),
            Schedule.new(5_000_000, 25_000_000, 449_929, 0.103),
            Schedule.new(25_000_000, Float::INFINITY, 2_509_929, 0.109),
          ]
        end

        def head_of_household_schedules
          [
            Schedule.new(0, 12_800,  0, 0.04),
            Schedule.new(12_800, 17_650, 512, 0.045),
            Schedule.new(17_650, 20_900, 730, 0.0525),
            Schedule.new(20_900, 107_650, 901, 0.055),
            Schedule.new(107_650, 269_300, 5_672, 0.06),
            Schedule.new(269_300, 1_616_450, 15_371, 0.0685),
            Schedule.new(1_616_450, 5_000_000, 107_651, 0.0965),
            Schedule.new(5_000_000, 25_000_000, 434_163, 0.0103),
            Schedule.new(25_000_000, Float::INFINITY, 2_494_163, 0.0109),
          ]
        end
      end

      class Schedule
        attr_reader :floor, :taxable_income_ceiling, :base_tax_amt, :tax_rate

        def initialize(floor, taxable_income_ceiling, base_tax_amt, tax_rate)
          @floor = floor
          @taxable_income_ceiling = taxable_income_ceiling
          @base_tax_amt = base_tax_amt
          @tax_rate = tax_rate
        end

        def valid_for(taxable_income)
          (floor < taxable_income) && (taxable_income <= taxable_income_ceiling)
        end

        def compute(taxable_income)
          # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#nys-tax-rate-schedule
          ((taxable_income - floor) * tax_rate) + base_tax_amt
        end
      end
    end
  end
end
