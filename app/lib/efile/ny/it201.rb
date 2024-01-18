module Efile
  module Ny
    class It201 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        @year = year
        @intake = intake
        @filing_status = intake.filing_status.to_sym # single, married_filing_jointly, that's all we support for now
        @direct_file_data = intake.direct_file_data
        @eligibility_lived_in_state = intake.eligibility_lived_in_state
        @dependent_count = intake.dependents.length

        @value_access_tracker = Efile::ValueAccessTracker.new(include_source: include_source)
        @lines = HashWithIndifferentAccess.new

        @it213 = Efile::Ny::It213.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
        # We aren't supporting the real property tax credit so IT-214 is not needed
        # @it214 = Efile::Ny::It214.new(
        #   value_access_tracker: @value_access_tracker,
        #   lines: @lines,
        #   intake: @intake
        # )
        @it215 = Efile::Ny::It215.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
        @it227 = Efile::Ny::It227.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines
        )
      end

      def calculate
        set_line(:IT201_LINE_1, @direct_file_data, :fed_wages)
        set_line(:IT201_LINE_2, @direct_file_data, :fed_taxable_income)
        set_line(:IT201_LINE_9, -> { 0 })
        set_line(:IT201_LINE_14, @direct_file_data, :fed_unemployment)
        set_line(:IT201_LINE_15, @direct_file_data, :fed_taxable_ssb)
        set_line(:IT201_LINE_17, :calculate_line_17)
        set_line(:IT201_LINE_18, @direct_file_data, :fed_total_adjustments)
        set_line(:IT201_LINE_19, :calculate_line_19)
        set_line(:IT201_LINE_21, @direct_file_data, :ny_public_employee_retirement_contributions)
        set_line(:IT201_LINE_24, :calculate_line_24)
        set_line(:IT201_LINE_25, -> { @lines[:IT201_LINE_4]&.value })
        set_line(:IT201_LINE_27, @direct_file_data, :fed_taxable_ssb)
        set_line(:IT201_LINE_32, :calculate_line_32)
        set_line(:IT201_LINE_33, :calculate_line_33)
        set_line(:IT201_LINE_34, :calculate_line_34)
        set_line(:IT201_LINE_35, :calculate_line_35)
        set_line(:IT201_LINE_36, -> { @dependent_count })
        set_line(:IT201_LINE_37, :calculate_line_37)
        set_line(:IT201_LINE_38, -> { @lines[:IT201_LINE_37]&.value })
        set_line(:IT201_LINE_39, :calculate_line_39)
        set_line(:IT201_LINE_40, :calculate_line_40)
        set_line(:IT201_LINE_43, :calculate_line_43)
        set_line(:IT201_LINE_44, :calculate_line_44)
        set_line(:IT201_LINE_46, :calculate_line_46)
        set_line(:IT201_LINE_47, :calculate_line_47)
        set_line(:IT201_LINE_47A, :calculate_line_47a)
        set_line(:IT201_LINE_48, :calculate_line_48)
        set_line(:IT201_LINE_49, :calculate_line_49)
        set_line(:IT201_LINE_52, :calculate_line_52)
        set_line(:IT201_LINE_54, :calculate_line_54)
        set_line(:IT201_LINE_58, :calculate_line_58)
        set_line(:IT201_LINE_59, @intake, :sales_use_tax)
        @it227.calculate
        set_line(:IT201_LINE_61, :calculate_line_61)
        set_line(:IT201_LINE_62, :calculate_line_62)
        @it213.calculate
        set_line(:IT201_LINE_63, :calculate_line_63)
        @it215.calculate
        set_line(:IT201_LINE_65, :calculate_line_65)
        # These two lines would be needed to add support for the IT-214 real property tax credit
        # We currently aren't supporting this, so IT-201 line 67 is always set to 0
        # @it214.calculate
        # set_line(:IT201_LINE_67, -> { @lines[:IT214_LINE_33].value })
        set_line(:IT201_LINE_67, -> { 0 })
        set_line(:IT201_LINE_69, :calculate_line_69)
        set_line(:IT201_LINE_69A, :calculate_line_69a)
        set_line(:IT201_LINE_70, -> { line_or_zero(:IT215_LINE_27) })
        set_line(:IT201_LINE_72, :calculate_line_72)
        set_line(:IT201_LINE_73, :calculate_line_73)
        set_line(:IT201_LINE_76, :calculate_line_76)
        set_line(:IT201_LINE_77, :calculate_line_77)
        set_line(:IT201_LINE_78, :calculate_line_78)
        set_line(:IT201_LINE_78B, :calculate_line_78b)
        set_line(:IT201_LINE_80, :calculate_line_80)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        #refund if amount is positive, owed if amount is negative
        line_or_zero(:IT201_LINE_76) - line_or_zero(:IT201_LINE_62)
      end

      private

      def calculate_line_17
        result = 0
        (1..16).each do |line_num|
          next if line_num == 12
          result += line_or_zero("IT201_LINE_#{line_num}")
        end

        result
      end

      def calculate_line_19
        line_or_zero(:IT201_LINE_17) - line_or_zero(:IT201_LINE_18)
      end

      def calculate_line_24
        result = 0
        (19..23).each do |line_num|
          result += line_or_zero("IT201_LINE_#{line_num}")
        end
        result
      end

      def calculate_line_32
        result = 0
        (25..31).each do |line_num|
          result += line_or_zero("IT201_LINE_#{line_num}")
        end
        result
      end

      def calculate_line_33
        line_or_zero(:IT201_LINE_24) - line_or_zero(:IT201_LINE_32)
      end

      def calculate_line_34
        # NY Standard Deductions for 2023
        if filing_status_single? && @direct_file_data.claimed_as_dependent?
          3_100
        elsif filing_status_single? || filing_status_mfs?
          8_000
        elsif filing_status_mfj? || filing_status_qw?
          16_050
        elsif filing_status_hoh?
          11_200
        end
      end

      def calculate_line_35
        result = line_or_zero(:IT201_LINE_33) - line_or_zero(:IT201_LINE_34)
        [result, 0].max
      end

      def calculate_line_37
        result = line_or_zero(:IT201_LINE_35) - (line_or_zero(:IT201_LINE_36) * 1000)
        [result, 0].max
      end

      def calculate_line_39
        # This was implemented based on the official instructions:
        # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#nys-tax-table
        agi = line_or_zero(:IT201_LINE_33)
        taxable_income = line_or_zero(:IT201_LINE_38)
        if agi <= 107_650
          # Note about tax tables and not using them:
          #   The instructions point to the use of tax tables if "NYS taxable income is less than $65,000"
          #   These are the tax tables: https://www.tax.ny.gov/pit/file/tax-tables/it201i-2023.htm
          #   The tax table values are themselves calculated using the NYS Tax Rate Schedule. After conferring
          #   with Courtney O'Reilly, it was clear that using the NYS Tax Rate Schedule was the best approach was to
          #   use the NYS Tax Rate Schedule for all NY AGI under $107,650 regardless of taxable income
          #
          # use the NYS tax rate schedule
          # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#nys-tax-rate-schedule
          result = NysTaxRateSchedule.calculate(taxable_income, @filing_status)
        else
          # use NYS tax computation worksheet
          # https://www.tax.ny.gov/forms/html-instructions/2023/it/it201i-2023.htm#tax-computation
          result = NysTaxComputation.calculate(agi, taxable_income, @filing_status)
        end
        result.round # rounding to the nearest dollar should be done as a final step, not before.
      end

      def calculate_line_40
        if @direct_file_data.claimed_as_dependent?
          0
        else
          # assumption: we don't support Build America Bonds (special condition code A6)
          nys_household_credit(line_or_zero(:IT201_LINE_19))
        end
      end

      def calculate_line_42
        # '42 Arizona adjusted gross income: Subtract lines 38 through 41 from line 37. If less than zero, enter “0”.'
        sum = 0
        (38..41).each do |line_num|
          sum += line_or_zero("IT201_LINE_#{line_num}").to_i
        end

        [line_or_zero(:IT201_LINE_37) - sum, 0].max
      end

      def calculate_line_43
        # as of Jan 2023 we do not support lines 41 and 42 so they will always be zero
        line_or_zero(:IT201_LINE_40) + line_or_zero(:IT201_LINE_41) + line_or_zero(:IT201_LINE_42)
      end

      def calculate_line_44
        [line_or_zero(:IT201_LINE_39) - line_or_zero(:IT201_LINE_43), 0].max
      end

      def calculate_line_46
        # as of Jan 2023 we do not support line 45 so this will be equal to line 44
        line_or_zero(:IT201_LINE_44) + line_or_zero(:IT201_LINE_45)
      end

      def calculate_line_47
        if @intake.nyc_full_year_resident_yes?
          line_or_zero(:IT201_LINE_38)
        else
          0
        end
      end

      def calculate_line_47a
        if @intake.nyc_full_year_resident_yes?
          nyc_tax_from_tables(@lines[:IT201_LINE_47].value)
        else
          0
        end
      end

      def calculate_line_48
        # If you are married and filing a joint New York State return and only one of you was a resident of New York City for all of 2022, do not enter an amount here. See the instructions for line 51.
        if @direct_file_data.claimed_as_dependent? || @intake.nyc_full_year_resident_no?
          0
        else
          nyc_household_credit(line_or_zero(:IT201_LINE_19))
        end
      end

      def calculate_line_49
        [line_or_zero(:IT201_LINE_47A) - line_or_zero(:IT201_LINE_48), 0].max
      end

      def calculate_line_52
        line_or_zero(:IT201_LINE_49) + line_or_zero(:IT201_LINE_50) + line_or_zero(:IT201_LINE_51)
      end

      def calculate_line_54
        [line_or_zero(:IT201_LINE_52) - line_or_zero(:IT201_LINE_53), 0].max
      end

      def calculate_line_58
        line_or_zero(:IT201_LINE_54) + line_or_zero(:IT201_LINE_54B) + line_or_zero(:IT201_LINE_55) + line_or_zero(:IT201_LINE_56) + line_or_zero(:IT201_LINE_57)
      end

      def calculate_line_61
        # as of Jan 2023 we do not support line 60 so it is always zero
        line_or_zero(:IT201_LINE_46) + line_or_zero(:IT201_LINE_58) + line_or_zero(:IT201_LINE_59) + line_or_zero(:IT201_LINE_60)
      end

      def calculate_line_62
        line_or_zero(:IT201_LINE_61)
      end

      def calculate_line_63
        if @direct_file_data.claimed_as_dependent?
          0
        else
          @lines[:IT213_LINE_14].value
        end
      end

      def calculate_line_65
        if @lines[:IT215_LINE_1]&.value.present? && !@lines[:IT215_LINE_2]&.value
          @lines[:IT215_LINE_16].value
        else
          0
        end
      end

      def calculate_line_69
        # From IT-201 instructions: Income, for purposes of determining your New York City school tax credit, means your
        # federal adjusted gross income from Form IT-201, line 19, minus distributions from an individual retirement
        # account and an individual retirement annuity, from Form IT-201, line 9, if they were included in your federal
        # adjusted gross income.
        income_eligible = (line_or_zero(:IT201_LINE_19) - line_or_zero(:IT201_LINE_9)) < 250_000
        return 0 unless income_eligible && @intake.nyc_full_year_resident_yes? && !@direct_file_data.claimed_as_dependent?

        @filing_status.in?([:single, :married_filing_separately, :head_of_household]) ? 63 : 125
      end

      def calculate_line_69a
        return 0 unless @intake.nyc_full_year_resident_yes? && !@direct_file_data.claimed_as_dependent?

        nyc_taxable_income = line_or_zero(:IT201_LINE_47)
        result = case @filing_status
                 when :married_filing_jointly, :qualifying_widow
                   if nyc_taxable_income.positive? && nyc_taxable_income <= 21_600
                     nyc_taxable_income * 0.00171
                   elsif nyc_taxable_income > 21_600 && nyc_taxable_income <= 500_000
                     37 + ((nyc_taxable_income - 21_600) * 0.00228)
                   end
                 when :single, :married_filing_separately
                   if nyc_taxable_income.positive? && nyc_taxable_income <= 12_000
                     nyc_taxable_income * 0.00171
                   elsif nyc_taxable_income > 12_000 && nyc_taxable_income <= 500_000
                     21 + ((nyc_taxable_income - 12_000) * 0.00228)
                   end
                 when :head_of_household
                   if nyc_taxable_income.positive? && nyc_taxable_income <= 14_400
                     nyc_taxable_income * 0.00171
                   elsif nyc_taxable_income > 14_400 && nyc_taxable_income <= 500_000
                     25 + ((nyc_taxable_income - 14_400) * 0.00228)
                   end
                 else
                   raise "Unknown filing status!"
                 end
        (result || 0).round
      end

      def calculate_line_72
        total_state_taxes_withheld = @direct_file_data.total_state_tax_withheld
        state_file_1099gs = @intake.state_file1099_gs
        state_file_1099gs.each do |state_file_1099g|
          total_state_taxes_withheld += state_file_1099g.state_income_tax_withheld
        end
        total_state_taxes_withheld
      end

      def calculate_line_73
        @direct_file_data.total_local_tax_withheld
      end

      def calculate_line_76
        result = 0
        (63..75).each do |line_num|
          result += line_or_zero("IT201_LINE_#{line_num}")
        end
        result += line_or_zero("IT201_LINE_69A")
        result
      end

      def calculate_line_77
        [line_or_zero(:IT201_LINE_76) - line_or_zero(:IT201_LINE_62), 0].max
      end

      def calculate_line_78
        line_or_zero(:IT201_LINE_77)
      end

      def calculate_line_78b
        line_or_zero(:IT201_LINE_78)
      end

      def calculate_line_80
        [line_or_zero(:IT201_LINE_62) - line_or_zero(:IT201_LINE_76), 0].max
      end

      def nyc_tax_from_tables(amount)
        # TODO: Can this be extracted into a NYSTaxTables class, where it's a public method, and the
        # TaxTables class is instantiated with the filing status? That way it could be directly unit tested;
        # right now it can't be cleanly extracted due to the dependency on filing_status_mfj.
        #
        # I want to leave it in here until we have at least one more such tax table.
        row = Struct.new(:floor, :ceiling, :cumulative, :rate)
        table =
          if filing_status_mfj? || filing_status_qw?
            [
              row.new(-Float::INFINITY, 21_600, 0, 0.03078),
              row.new(21_600, 45_000, 665, 0.03762),
              row.new(45_000, 90_000, 1_545, 0.03819),
              row.new(90_000, Float::INFINITY, 3_264, 0.03876)
            ]
          elsif filing_status_hoh?
            [
              row.new(-Float::INFINITY, 14_400, 0, 0.03078),
              row.new(14_400, 30_000, 443, 0.03762),
              row.new(30_000, 60_000, 1_030, 0.03819),
              row.new(60_000, Float::INFINITY, 2_176, 0.03876)
            ]
          else
            [
              row.new(-Float::INFINITY, 12_000, 0, 0.03078),
              row.new(12_000, 25_000, 369, 0.03762),
              row.new(25_000, 50_000, 858, 0.03819),
              row.new(50_000, Float::INFINITY, 1_813, 0.03876)
            ]
          end

        table_row = table.reverse.find do |table_row|
          amount > table_row.floor && (amount <= table_row.ceiling)
        end

        (table_row.cumulative + ((table_row.floor == -Float::INFINITY ? amount : amount - table_row.floor) * table_row.rate)).round
      end

      def nys_household_credit(amount)
        # The NYS household credit table in IT-201 instructions starts at
        # household size of 1. So `amount_1` in the struct is for household
        # size of 1.
        row = Struct.new(:floor, :ceiling, :amounts, :household_member_increment)
        table =
          if filing_status_single?
            [
              row.new(-Float::INFINITY, 5000, [75, 75, 75, 75, 75, 75, 75], 0),
              row.new(5_000, 6_000, [60, 60, 60, 60, 60, 60, 60], 0),
              row.new(6_000, 7_000, [50, 50, 50, 50, 50, 50, 50], 0),
              row.new(7_000, 20_000, [45, 45, 45, 45, 45, 45, 45], 0),
              row.new(20_000, 25_000, [40, 40, 40, 40, 40, 40, 40], 0),
              row.new(25_000, 28_000, [20, 20, 20, 20, 20, 20, 20], 0),
              row.new(28_000, Float::INFINITY, [0, 0, 0, 0, 0, 0, 0], 0)
            ]
          elsif filing_status_mfs?
            [
              row.new(-Float::INFINITY, 5_000, [45, 53, 60, 68, 75, 83, 90], 8),
              row.new(5_000, 6_000, [38, 45, 53, 60, 68, 75, 84], 8),
              row.new(6_000, 7_000, [33, 40, 48, 55, 63, 70, 78], 8),
              row.new(7_000, 20_000, [30, 38, 45, 53, 60, 68, 75], 8),
              row.new(20_000, 22_000, [30, 35, 40, 45, 50, 55, 60], 5),
              row.new(22_000, 25_000, [25, 30, 35, 40, 45, 50, 55], 5),
              row.new(25_000, 28_000, [20, 23, 25, 28, 30, 33, 35], 3),
              row.new(28_000, 32_000, [10, 13, 15, 18, 20, 23, 25], 3),
              row.new(32_000, Float::INFINITY, [0, 0, 0, 0, 0, 0, 0], 0)
            ]
          else
            [
              row.new(-Float::INFINITY, 5_000, [90, 105, 120, 135, 150, 165, 180], 15),
              row.new(5_000, 6_000, [75, 90, 105, 120, 135, 150, 165], 15),
              row.new(6_000, 7_000, [65, 80, 95, 110, 125, 140, 155], 15),
              row.new(7_000, 20_000, [60, 75, 90, 105, 120, 135, 150], 15),
              row.new(20_000, 22_000, [60, 70, 80, 90, 100, 110, 120], 10),
              row.new(22_000, 25_000, [50, 60, 70, 80, 90, 100, 110], 10),
              row.new(25_000, 28_000, [40, 45, 50, 55, 60, 65, 70], 5),
              row.new(28_000, 32_000, [20, 25, 30, 35, 40, 45, 50], 5),
              row.new(32_000, Float::INFINITY, [0, 0, 0, 0, 0, 0, 0], 0)
            ]
          end
        num_filers = filing_status_mfj? || filing_status_mfs? ? 2 : 1
        household_size = @dependent_count + num_filers
        table_row = table.reverse.find do |tr|
          amount > tr.floor && (amount <= tr.ceiling)
        end
        if household_size > 7
          table_row.amounts[6] + ((household_size - 7) * table_row.household_member_increment)
        else
          table_row.amounts[household_size - 1]
        end
      end

      def nyc_household_credit(amount)
        # The NYC household credit table in IT-201 instructions starts at
        # household size of 1. So `amount_1` in the struct is for household
        # size of 1.
        row = Struct.new(:floor, :ceiling, :amounts, :household_member_increment)
        table =
          if filing_status_single?
            [
              row.new(-Float::INFINITY, 10_000, [15, 15, 15, 15, 15, 15, 15], 0),
              row.new(10_000, 12_500, [10, 10, 10, 10, 10, 10, 10], 0),
              row.new(12_500, Float::INFINITY, [0, 0, 0, 0, 0, 0, 0], 0)
            ]
          elsif filing_status_mfs?
            [
              row.new(-Float::INFINITY, 15_000, [15, 30, 45, 60, 75, 90, 105], 15),
              row.new(15_000, 17_500, [13, 25, 38, 50, 63, 75, 88], 13),
              row.new(17_500, 20_000, [8, 15, 23, 30, 38, 45, 53], 8),
              row.new(20_000, 22_500, [5, 10, 15, 20, 25, 30, 35], 5),
              row.new(22_500, Float::INFINITY, [0, 0, 0, 0, 0, 0, 0], 0)
            ]
          else
            [
              row.new(-Float::INFINITY, 15_000, [30, 60, 90, 120, 150, 180, 210], 30),
              row.new(15_000, 17_500, [25, 50, 75, 100, 125, 150, 175], 25),
              row.new(17_500, 20_000, [15, 30, 45, 60, 75, 90, 105], 15),
              row.new(20_000, 22_500, [10, 20, 30, 40, 50, 60, 70], 10),
              row.new(22_500, Float::INFINITY, [0, 0, 0, 0, 0, 0, 0], 0)
            ]
          end
        num_filers = filing_status_mfj? || filing_status_mfs? ? 2 : 1
        household_size = @dependent_count + num_filers
        table_row = table.reverse.find do |tr|
          amount > tr.floor && (amount <= tr.ceiling)
        end
        if household_size > 7
          table_row.amounts[6] + ((household_size - 7) * table_row.household_member_increment)
        else
          table_row.amounts[household_size - 1]
        end
      end
    end
  end
end
