module StateFile
  module Ny
    module Efile
      class NysTaxComputation
        # Implements the NYS Tax Computation, for use with NY AGI over $107,650, as documented in the IT-201 instructions
        # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#tax-computation
        # Worksheet numbers in the comments correspond to worksheets in the instructions

        AGI_TOP_BRACKET_THRESHOLD = 25_000_000 # used as the upper AGI limit for all mid and bottom bracket worksheets

        class << self
          def calculate(agi, taxable_income, filing_status)
            # Get the set of worksheets for the filing status
            worksheets = worksheets_for_filing_status(filing_status)
            # Find the correct worksheet based on AGI and taxable income
            worksheet = worksheets.find { |w| w.valid_for(agi, taxable_income) }
            # use the worksheet to compute the NYS tax amount
            worksheet.compute(agi, taxable_income, filing_status)
          end

          private

          def worksheets_for_filing_status(filing_status)
            case filing_status
            when :married_filing_jointly, :qualifying_widow then joint_filer_worksheets
            when :single, :married_filing_separately then single_filer_worksheets
            when :head_of_household then head_of_household_worksheets
            end
          end

          def joint_filer_worksheets
            [
              WorksheetBottomBracket.new( 107_650,           161_550, 0.055), # worksheet 1
              WorksheetMidBracket.new(    161_550,           323_200,    333,    807), # worksheet 2
              WorksheetMidBracket.new(    323_200,         2_155_350,  1_140,  2_747), # worksheet 3
              WorksheetMidBracket.new(    2_155_350,       5_000_000,  3_887, 60_350), # worksheet 4
              WorksheetMidBracket.new(    5_000_000, Float::INFINITY, 64_237, 32_500), # worksheet 5
              WorksheetTopBracket.new # worksheet 6
            ]
          end

          def single_filer_worksheets
            [
              WorksheetBottomBracket.new(   107_650,        215_400, 0.06), # worksheet 7
              WorksheetMidBracket.new(      215_400,      1_077_550,    568,  1_831), # worksheet 8
              WorksheetMidBracket.new(    1_077_550,      5_000_000,  2_399, 30_172), # worksheet 9
              WorksheetMidBracket.new(   5_000_000, Float::INFINITY, 32_571, 32_500), # worksheet 10
              WorksheetTopBracket.new # worksheet 11
            ]
          end

          def head_of_household_worksheets
            [
              WorksheetBottomBracket.new(  107_650,         269_300, 0.06), # worksheet 12
              WorksheetMidBracket.new(     269_300,       1_616_450,    787,  2_289), # worksheet 13
              WorksheetMidBracket.new(   1_616_450,       5_000_000,  3_076, 45_261), # worksheet 14
              WorksheetMidBracket.new(   5_000_000, Float::INFINITY, 48_337, 32_500), # worksheet 15
              WorksheetTopBracket.new # worksheet 16
            ]
          end
        end


        class Worksheet
          attr_reader :floor, :taxable_income_ceiling

          def initialize(floor, taxable_income_ceiling)
            # floor is used as the bottom limit for both NY AGI & taxable income
            @floor = floor
            @taxable_income_ceiling = taxable_income_ceiling
          end

          def valid_for(agi, taxable_income)
            agi_within_bracket = (floor < agi) && (agi <= AGI_TOP_BRACKET_THRESHOLD)
            taxable_income_within_bracket = (floor < taxable_income) && (taxable_income <= taxable_income_ceiling)
            agi_within_bracket && taxable_income_within_bracket
          end
        end

        class WorksheetBottomBracket < Worksheet
          attr_reader :rate

          def initialize(floor, taxable_income_ceiling, rate)
            @rate = rate
            super(floor, taxable_income_ceiling)
          end

          def valid_for(agi, taxable_income)
            agi_within_bracket = (floor < agi) && (agi <= AGI_TOP_BRACKET_THRESHOLD)
            taxable_income_within_bracket = (taxable_income <= taxable_income_ceiling)
            agi_within_bracket && taxable_income_within_bracket
          end

          def compute(agi, taxable_income, filing_status)
            step_3 = taxable_income * @rate
            return step_3 if agi >= 157_650

            step_4 = NysTaxRateSchedule.calculate(taxable_income, filing_status)
            step_5 = step_3 - step_4
            step_6 = agi - floor
            step_7 = (step_6 / 50_000.to_f).round(4) # ensure division by float, then round to 4th decimal place
            step_8 = step_5 * step_7
            step_4 + step_8
          end
        end

        class WorksheetMidBracket < Worksheet
          attr_reader :recapture_base_amt, :incremental_benefit_amt

          def initialize(floor, taxable_income_ceiling, recapture_base_amt, incremental_benefit_amt)
            @recapture_base_amt = recapture_base_amt
            @incremental_benefit_amt = incremental_benefit_amt
            super(floor, taxable_income_ceiling)
          end

          def compute(agi, taxable_income, filing_status)
            step_3 = NysTaxRateSchedule.calculate(taxable_income, filing_status)
            step_6 = agi - floor
            step_7 = [step_6, 50_000].min
            step_8 = (step_7 / 50_000.to_f).round(4) # ensure division by float, then round to 4th decimal place
            step_9 = incremental_benefit_amt * step_8
            step_3 + recapture_base_amt + step_9
          end
        end

        class WorksheetTopBracket
          attr_reader :rate

          def initialize
            @rate = 0.109
          end

          def valid_for(agi, _taxable_income)
            AGI_TOP_BRACKET_THRESHOLD < agi
          end

          def compute(_agi, taxable_income, _filing_status)
            taxable_income * rate
          end
        end
      end
    end
  end
end
