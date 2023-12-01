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
        # TODO: are we supporting MCTMT lines 54a-54e?
        set_line(:IT201_LINE_58, :calculate_line_58)
        set_line(:IT201_LINE_59, @intake, :sales_use_tax)
        @it227.calculate
        # TODO: this is always 0, should we know the real value?
        set_line(:IT201_LINE_60, -> { @lines[:IT227_PART_2_LINE_1].value })
        set_line(:IT201_LINE_61, :calculate_line_61)
        set_line(:IT201_LINE_62, :calculate_line_62)
        @it213.calculate
        set_line(:IT201_LINE_63, -> { @lines[:IT213_LINE_14].value })
        @it215.calculate
        set_line(:IT201_LINE_65, -> { @lines[:IT215_LINE_16].value })
        # These two lines would be needed to add support for the IT-214 real property tax credit
        # We currently aren't supporting this, so IT-201 line 67 is always set to 0
        # @it214.calculate
        # set_line(:IT201_LINE_67, -> { @lines[:IT214_LINE_33].value })
        set_line(:IT201_LINE_67, -> { 0 })
        set_line(:IT201_LINE_69, :calculate_line_69)
        set_line(:IT201_LINE_69A, :calculate_line_69a)
        set_line(:IT201_LINE_70, -> { @lines[:IT215_LINE_27] ? @lines[:IT215_LINE_27].value : 0})
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
        line_or_zero(:IT201_LINE_17) - line_or_zero(:IT201_LINE_18).abs
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
        if filing_status_single?
          if @direct_file_data.claimed_as_dependent?
            3100
          else
            8000
          end
        elsif filing_status_hoh?
          11200
        elsif filing_status_mfj?
          16050
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

      def nys_tax_from_tables(taxable_income)
        table =
          if filing_status_mfj?
            [
              TaxTableRow.new(-Float::INFINITY, 17_150, 0, 0.0400),
              TaxTableRow.new(17_150, 23_600, 686, 0.0450),
              TaxTableRow.new(23_600, 27_900, 976, 0.0525),
              TaxTableRow.new(27_900, 161_550, 1_202, 0.0585),
              TaxTableRow.new(161_550, 323_200, 9_021, 0.0625),
              TaxTableRow.new(323_200, 2_155_350, 19_124, 0.0685),
              TaxTableRow.new(2_155_350, 5_000_000, 144_626, 0.0965),
              TaxTableRow.new(5_000_000, 25_000_000, 419_135, 0.103),
              TaxTableRow.new(25_000_000, Float::INFINITY, 247_9135, 0.109)
            ]
          else
            [
              TaxTableRow.new(-Float::INFINITY, 8_500, 0, 0.0400),
              TaxTableRow.new(8_500, 11_700, 340, 0.0450),
              TaxTableRow.new(11_700, 13_900, 484, 0.0525),
              TaxTableRow.new(13_900, 80_650, 600, 0.0585),
              TaxTableRow.new(80_650, 215_400, 4_504, 0.0625),
              TaxTableRow.new(215_400, 1_077_550, 12_926, 0.0685),
              TaxTableRow.new(1_077_550, 5_000_000, 71_984, 0.0965),
              TaxTableRow.new(5_000_000, 25_000_000, 450_500, 0.103),
              TaxTableRow.new(25_000_000, Float::INFINITY, 2_510_500, 0.109)
            ]
          end
        table_row = table.reverse.find do |table_row|
          taxable_income > table_row.floor && (taxable_income <= table_row.ceiling)
        end

        table_row.compute(taxable_income)
      end

      def round_to_decimal(val, digits)
        ten_to_the_digits_power = 10 ** digits
        (val * ten_to_the_digits_power).round / (ten_to_the_digits_power * 1.0)
      end

      def calculate_line_39
        agi = line_or_zero(:IT201_LINE_33)
        taxable_income = line_or_zero(:IT201_LINE_38)
        if agi <= 107_650
          return nys_tax_from_tables(taxable_income).round
        end
        result = case @filing_status
                 when :married_filing_jointly, :qualifying_widow
                   if agi > 107_650 && agi <= 25_000_000 && taxable_income <= 161_550
                     if agi >= 157_650
                       taxable_income * 0.0585
                     else
                       step_3_flat_tax = (taxable_income * 0.0585).round
                       step_4_usual_tax = nys_tax_from_tables(taxable_income)
                       step_5_flat_tax_extra_amount = step_3_flat_tax - step_4_usual_tax
                       step_6_marginal_taxable_amount = agi - 107_650
                       step_7 = round_to_decimal(step_6_marginal_taxable_amount / 50_000, 4)
                       step_8 = (step_5_flat_tax_extra_amount * step_7).round
                       step_4_usual_tax + step_8
                     end
                   elsif agi > 161_550 && agi <= 25_000_000 && taxable_income > 161_550 && taxable_income <= 323_200
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 161_550
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (646 * step_8).round
                     step_3_usual_tax + 430 + step_9
                   elsif agi > 323_200 && agi <= 25_000_000 && taxable_income > 323_200 && taxable_income <= 2_155_350
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 323_200
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (1_940 * step_8).round
                     step_3_usual_tax + 1_076 + step_9
                   elsif agi > 2155350 && agi <= 25000000 && taxable_income > 2155350 && taxable_income <= 5000000
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 2_155_350
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (60_349 * step_8).round
                     step_3_usual_tax + 3_016 + step_9
                   elsif agi > 5_000_000 && agi <= 25_000_000 && taxable_income > 5_000_000
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 5_000_000
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (63_365 * step_8).round
                     step_3_usual_tax + 32_500 + step_9
                   elsif agi > 25_050_000
                     taxable_income * 0.109
                   else
                     # if 25_000_000 < agi < 25_050_000 TODO
                     raise NotImplementedError, "Unsure how to handle AGI in this range"
                   end
                 when :single, :married_filing_separately
                   if agi > 107_650 && agi <= 25_000_000 && taxable_income <= 215_400
                     if agi >= 157_650
                       taxable_income * 0.0625
                     else
                       step_3_flat_tax = (taxable_income * 0.0625).round
                       step_4_usual_tax = nys_tax_from_tables(taxable_income)
                       step_5_flat_tax_extra_amount = step_3_flat_tax - step_4_usual_tax
                       step_6_marginal_taxable_amount = agi - 107_650
                       step_7 = round_to_decimal(step_6_marginal_taxable_amount / 50_000, 4)
                       step_8 = (step_5_flat_tax_extra_amount * step_7).round
                       step_4_usual_tax + step_8
                     end
                   elsif agi > 215_400 && agi <= 25_000_000 && taxable_income > 215_400 && taxable_income <= 1_077_550
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 215_400
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (1_293 * step_8).round
                     step_3_usual_tax + 536 + step_9
                   elsif agi > 1_077_550 && agi <= 25_000_000 && taxable_income > 1_077_550 && taxable_income <= 5_000_000
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 1_077_550
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (30_171 * step_8).round
                     step_3_usual_tax + 1_829 + step_9
                   elsif agi > 5_000_000 && agi <= 25_000_000 && taxable_income > 5_000_000
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 5_000_000
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (32_500 * step_8).round
                     step_3_usual_tax + 32_000 + step_9
                   else
                     taxable_income * 0.109
                   end
                 when :head_of_household
                   if agi > 107_650 && agi <= 25_000_000 && taxable_income <= 269_300
                     if agi >= 157_650
                       taxable_income * 0.0625
                     else
                       step_3_flat_tax = (taxable_income * 0.0625).round
                       step_4_usual_tax = nys_tax_from_tables(taxable_income)
                       step_5_flat_tax_extra_amount = step_3_flat_tax - step_4_usual_tax
                       step_6_marginal_taxable_amount = agi - 107_650
                       step_7 = round_to_decimal(step_6_marginal_taxable_amount / 50_000, 4)
                       step_8 = (step_5_flat_tax_extra_amount * step_7).round
                       step_4_usual_tax + step_8
                     end
                   elsif agi > 269_300 && agi <= 25_000_000 && taxable_income > 269_300 && taxable_income <= 1_616_450
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 269_300
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (1_616 * step_8).round
                     step_3_usual_tax + 752 + step_9
                   elsif agi > 1_616_450 && agi <= 25_000_000 && taxable_income > 1_616_450 && taxable_income <= 5_000_000
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 1_616_450
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (45_261 * step_8).round
                     step_3_usual_tax + 2_368 + step_9
                   elsif agi > 5_000_000 && agi <= 25_000_000 && taxable_income > 5_000_000
                     step_3_usual_tax = nys_tax_from_tables(taxable_income)
                     step_6_marginal_taxable_amount = agi - 5_000_000
                     step_7 = [step_6_marginal_taxable_amount, 50_000].min
                     step_8 = round_to_decimal(step_7 / 50_000, 4)
                     step_9 = (32_500 * step_8).round
                     step_3_usual_tax + 47_629 + step_9
                   elsif agi > 25_000_000
                     taxable_income * 0.109
                   end
                 else
                   raise "Unknown filing status!"
                 end
        result.round
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
        line_or_zero(:IT201_LINE_40) + line_or_zero(:IT201_LINE_41) + line_or_zero(:IT201_LINE_42)
      end

      def calculate_line_44
        [line_or_zero(:IT201_LINE_39) - line_or_zero(:IT201_LINE_43), 0].max
      end

      def calculate_line_46
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
        line_or_zero(:IT201_LINE_46) + line_or_zero(:IT201_LINE_58) + line_or_zero(:IT201_LINE_59) + line_or_zero(:IT201_LINE_60)
      end

      def calculate_line_62
        line_or_zero(:IT201_LINE_61)
      end

      def calculate_line_69
        # From IT-201 instructions: Income, for purposes of determining your New York City school tax credit, means your
        # federal adjusted gross income from Form IT-201, line 19, minus distributions from an individual retirement
        # account and an individual retirement annuity, from Form IT-201, line 9, if they were included in your federal
        # adjusted gross income.
        if (line_or_zero(:IT201_LINE_19) - line_or_zero(:IT201_LINE_9)) < 250_000 && @intake.nyc_full_year_resident_yes?
          if @filing_status.in?([:single, :married_filing_separately, :head_of_household])
            63
          else
            125
          end
        else
          0
        end
      end

      def calculate_line_69a
        return 0 unless @intake.nyc_full_year_resident_yes? && !@direct_file_data.claimed_as_dependent?

        nyc_taxable_income = line_or_zero(:IT201_LINE_47)
        result = case @filing_status
                 when :married_filing_jointly, :qualifying_widow
                   if nyc_taxable_income.positive? && nyc_taxable_income <= 21_600
                     nyc_taxable_income * 0.171
                   elsif nyc_taxable_income > 21_600 && nyc_taxable_income <= 500_000
                     37 + ((nyc_taxable_income - 21_600) * 0.228)
                   end
                 when :single, :married_filing_separately
                   if nyc_taxable_income.positive? && nyc_taxable_income <= 12_000
                     nyc_taxable_income * 0.171
                   elsif nyc_taxable_income > 12_000 && nyc_taxable_income <= 500_000
                     21 + ((nyc_taxable_income - 12_000) * 0.228)
                   end
                 when :head_of_household
                   if nyc_taxable_income.positive? && nyc_taxable_income <= 14_400
                     nyc_taxable_income * 0.171
                   elsif nyc_taxable_income > 14_400 && nyc_taxable_income <= 500_000
                     25 + ((nyc_taxable_income - 14_400) * 0.228)
                   end
                 else
                   raise "Unknown filing status!"
                 end
        (result || 0).round
      end

      def calculate_line_72
        0 # TODO: Computed from W-2 and 1099G forms and their NYS wrapper, IT-2
      end

      def calculate_line_73
        0 # TODO: Computed from W-2 forms and their NYS wrapper, IT-2
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
          if filing_status_mfj?
            [
              row.new(-Float::INFINITY, 21600, 0, 0.03078),
              row.new(21600, 45000, 665, 0.03762),
              row.new(45000, 90000, 1545, 0.03819),
              row.new(90000, Float::INFINITY, 3264, 0.03876)
            ]
          else
            [
              row.new(-Float::INFINITY, 12000, 0, 0.03078),
              row.new(12000, 25000, 369, 0.03762),
              row.new(25000, 50000, 858, 0.03819),
              row.new(50000, Float::INFINITY, 1813, 0.03876)
            ]
          end

        table_row = table.reverse.find do |table_row|
          amount > table_row.floor && (amount <= table_row.ceiling)
        end

        (table_row.cumulative + ((table_row.floor == -Float::INFINITY ? amount : amount - table_row.floor) * table_row.rate)).round
      end

      def nys_household_credit(amount)
        # The NYS household credit table in IT-201 instructions starts at
        # household size of 1. So `amount` in the struct is for household
        # size of 1.
        row = Struct.new(:floor, :ceiling, :amount, :household_member_increment)
        table =
          if filing_status_mfj?
            [
              row.new(-Float::INFINITY, 5000, 45, 8),
              row.new(5_000, 6_000, 38, 8),
              row.new(6_000, 7_000, 33, 8),
              row.new(7_000, 20_000, 30, 8),
              row.new(20_000, 22_000, 30, 5),
              row.new(22_000, 25_000, 25, 5),
              row.new(25_000, 28_000, 20, 3),
              row.new(28_000, 32_000, 10, 3),
              row.new(32_000, Float::INFINITY, 0, 0)
            ]
          else
            [
              row.new(-Float::INFINITY, 5000, 75, 0),
              row.new(5_000, 6_000, 60, 0),
              row.new(6_000, 7_000, 50, 0),
              row.new(7_000, 20_000, 45, 0),
              row.new(20_000, 25_000, 40, 0),
              row.new(25_000, 28_000, 20, 0),
              row.new(28_000, Float::INFINITY, 0, 0)
            ]
          end
        num_filers =
          if filing_status_mfj?
            2
          else
            1
          end
        household_size = @dependent_count + num_filers
        table_row = table.reverse.find do |table_row|
          amount > table_row.floor && (amount <= table_row.ceiling)
        end
        table_row.amount + ((household_size - 1) * table_row.household_member_increment)
      end

      def nyc_household_credit(amount)
        # The NYC household credit table in IT-201 instructions starts at
        # household size of 1. So `amount` in the struct is for household
        # size of 1.
        row = Struct.new(:floor, :ceiling, :amount, :household_member_increment)
        table = if filing_status_mfj?
          [
            row.new(-Float::INFINITY, 15_000, 30, 30),
            row.new(15_000, 17_500, 25, 25),
            row.new(17_500, 20_000, 15, 15),
            row.new(20_000, 22_500, 10, 10),
            row.new(22_500, Float::INFINITY, 0, 0)
          ]
        else
          [
            row.new(-Float::INFINITY, 10_000, 15, 0),
            row.new(10_000, 12_500, 10, 0),
            row.new(12_500, Float::INFINITY, 0, 0)
          ]
        end

        num_filers =
          if filing_status_mfj?
            2
          else
            1
          end
        household_size = @dependent_count + num_filers
        table_row = table.reverse.find do |table_row|
          amount > table_row.floor && (amount <= table_row.ceiling)
        end
        table_row.amount + ((household_size - 1) * table_row.household_member_increment)
      end
    end

    class TaxTableRow
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
