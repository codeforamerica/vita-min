module Efile
  module Ny
    class It201 < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, filing_status:, claimed_as_dependent:, dependent_count:, input_lines:, it213:, it214:, it215:, it227:)
        @year = year

        @filing_status = filing_status # single, married_filing_jointly, that's all we support for now
        @claimed_as_dependent = claimed_as_dependent # true/false
        @dependent_count = dependent_count # number
        @value_access_tracker = Efile::ValueAccessTracker.new
        input_lines.each_value { |l| l.value_access_tracker = @value_access_tracker }
        @lines = HashWithIndifferentAccess.new(input_lines)
        [it213, it214, it215, it227].each do |form|
          form.value_access_tracker = @value_access_tracker
          form.lines = @lines
        end
        @it213 = it213
        @it214 = it214
        @it215 = it215
        @it227 = it227
      end

      def calculate
        set_line(:AMT_60E, -> { @it227.calculate[:part2_line1] })
        set_line(:AMT_65, -> { @it215.calculate[:line16] })
        set_line(:AMT_67, -> { @it214.calculate[:line33] })
        set_line(:AMT_17, -> { calculate_line_17 })
        set_line(:AMT_19, -> { calculate_line_19 })
        set_line(:AMT_19A, -> { calculate_line_19a })
        set_line(:AMT_24, -> { calculate_line_24 })
        set_line(:AMT_25, -> { @lines[:AMT_4]&.value })
        set_line(:AMT_32, -> { calculate_line_32 })
        set_line(:AMT_33, -> { calculate_line_33 })
        set_line(:AMT_34, -> { calculate_line_34 })
        set_line(:AMT_35, -> { calculate_line_35 })
        set_line(:AMT_36, -> { @dependent_count })
        set_line(:AMT_37, -> { calculate_line_37 })
        set_line(:AMT_38, -> { @lines[:AMT_37]&.value })
        set_line(:AMT_39, -> { calculate_line_39 })
        set_line(:AMT_40, -> { calculate_line_40 })
        set_line(:AMT_43, -> { calculate_line_43 })
        set_line(:AMT_44, -> { calculate_line_44 })
        set_line(:AMT_46, -> { calculate_line_46 })
        set_line(:AMT_47, -> { calculate_line_47 })
        set_line(:AMT_47A, -> { calculate_line_47a })
        set_line(:AMT_48, -> { calculate_line_48 })
        set_line(:AMT_49, -> { calculate_line_49 })
        set_line(:AMT_52, -> { calculate_line_52 })
        set_line(:AMT_54, -> { calculate_line_54 })
        set_line(:AMT_54B, -> { calculate_line_54b })
        set_line(:AMT_58, -> { calculate_line_58 })
        set_line(:AMT_61, -> { calculate_line_61 })
        set_line(:AMT_62, -> { calculate_line_62 })
        @it213.calculate
        set_line(:AMT_63, -> { @lines[:IT213_AMT_16].value })
        set_line(:AMT_69, -> { calculate_line_69 })
        set_line(:AMT_69A, -> { calculate_line_69a })
        set_line(:AMT_70, -> { calculate_line_70 })
        set_line(:AMT_73, -> { calculate_line_72 })
        set_line(:AMT_73, -> { calculate_line_73 })
        set_line(:AMT_76, -> { calculate_line_76 })
        set_line(:AMT_77, -> { calculate_line_77 })
        set_line(:AMT_78, -> { calculate_line_78 })
        set_line(:AMT_78B, -> { calculate_line_78b })
        set_line(:AMT_80, -> { calculate_line_80 })
        @lines.transform_values(&:value)
      end

      private

      def calculate_line_17
        result = 0
        (1..16).each do |line_num|
          next if line_num == 12
          result += line_or_zero("AMT_#{line_num}")
        end

        result
      end

      def calculate_line_19
        line_or_zero(:AMT_17) - line_or_zero(:AMT_18).abs
      end

      def calculate_line_19a
        # TODO: Add line 19A worksheet
        line_or_zero(:AMT_19)
      end

      def calculate_line_24
        result = 0
        result += line_or_zero(:AMT_19A)
        (20..23).each do |line_num|
          result += line_or_zero("AMT_#{line_num}")
        end
        result
      end

      def calculate_line_32
        result = 0
        (25..31).each do |line_num|
          result += line_or_zero("AMT_#{line_num}")
        end
        result
      end

      def calculate_line_33
        line_or_zero(:AMT_24) - line_or_zero(:AMT_32)
      end

      def calculate_line_34
        if filing_status_single?
          if @claimed_as_dependent
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
        result = line_or_zero(:AMT_33) - line_or_zero(:AMT_34)
        [result, 0].max
      end

      def calculate_line_37
        result = line_or_zero(:AMT_35) - (line_or_zero(:AMT_36) * 1000)
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
        agi = line_or_zero(:AMT_33)
        taxable_income = line_or_zero(:AMT_38)
        if agi <= 107_650
          return nys_tax_from_tables(taxable_income)
        end
        case @filing_status
        when 1 || 5
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
        when 1 || 3
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
        when 4
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
          0
        end
      end

      def calculate_line_40
        if @claimed_as_dependent
          0
        else
          # assumption: we don't support Build America Bonds (special condition code A6)
          nys_household_credit(line_or_zero(:AMT_19A))
        end
      end

      def calculate_line_43
        line_or_zero(:AMT_40) + line_or_zero(:AMT_41) + line_or_zero(:AMT_42)
      end

      def calculate_line_44
        [line_or_zero(:AMT_39) - line_or_zero(:AMT_43), 0].max
      end

      def calculate_line_46
        line_or_zero(:AMT_44) + line_or_zero(:AMT_45)
      end

      def calculate_line_47
        if full_year_nyc_resident?
          line_or_zero(:AMT_38)
        else
          0
        end
      end

      def calculate_line_47a
        if full_year_nyc_resident?
          nyc_tax_from_tables(@computed[:AMT_47])
        else
          0
        end
      end

      def calculate_line_48
        # If you are married and filing a joint New York State return and only one of you was a resident of New York City for all of 2022, do not enter an amount here. See the instructions for line 51.
        if @claimed_as_dependent || !full_year_nyc_resident?
          0
        else
          nyc_household_credit(line_or_zero(:AMT_19A))
        end
      end

      def calculate_line_49
        [line_or_zero(:AMT_47A) - line_or_zero(:AMT_48), 0].max
      end

      def calculate_line_52
        line_or_zero(:AMT_49) + line_or_zero(:AMT_50) + line_or_zero(:AMT_51)
      end

      def calculate_line_54
        [line_or_zero(:AMT_52) - line_or_zero(:AMT_53), 0].max
      end

      def calculate_line_54b
        (line_or_zero(:AMT_54A) * 0.0034).round
      end

      def calculate_line_58
        line_or_zero(:AMT_54) + line_or_zero(:AMT_54B) + line_or_zero(:AMT_55) + line_or_zero(:AMT_56) + line_or_zero(:AMT_57)
      end

      def calculate_line_61
        line_or_zero(:AMT_46) + line_or_zero(:AMT_58) + line_or_zero(:AMT_59) + line_or_zero(:AMT_60)
      end

      def calculate_line_62
        line_or_zero(:AMT_61)
      end

      def calculate_line_69
        if line_or_zero(:AMT_19) < 250_000 && full_year_nyc_resident?
          # income calculated as 19a - 9. 9 is not supported and 19a is 19
          if @filing_status == 1 || 3 || 4
            63
          else
            125
          end
        else
          0 # TODO: Ask product if we should support part-year NYC residents
        end
      end

      def calculate_line_69a
        # TODO: For part-year city residents in 2022, need to use the amount from Form IT-360.1, line 47 for nyc_taxable_income
        nyc_taxable_income = line_or_zero(:AMT_47)
        if full_year_nyc_resident? && @claimed_as_dependent == false
          case @filing_status
          when 2 || 5
            if nyc_taxable_income.positive? && nyc_taxable_income <= 21_600
              nyc_taxable_income * 0.171
            elsif nyc_taxable_income > 21_600 && nyc_taxable_income <= 500_000
              37 + ((nyc_taxable_income - 21_600) * 0.228)
            end
          when 1 || 3
            if nyc_taxable_income.positive? && nyc_taxable_income <= 12_000
              nyc_taxable_income * 0.171
            elsif nyc_taxable_income > 12_000 && nyc_taxable_income <= 500_000
              21 + ((nyc_taxable_income - 12_000) * 0.228)
            end
          when 4
            if nyc_taxable_income.positive? && nyc_taxable_income <= 14_400
              nyc_taxable_income * 0.171
            elsif nyc_taxable_income > 14_400 && nyc_taxable_income <= 500_000
              25 + ((nyc_taxable_income - 14_400) * 0.228)
            end
          else
            0
          end
        else
          0
        end
      end

      def calculate_line_70
        # Taken from excel formula as the PDF was more complicated
        if full_year_nyc_resident? && @claimed_as_dependent == false
          @it215.calculate[:line27]
        else
          0
        end
      end

      def calculate_line_72
        0 # TODO: Computed from W-2 forms and their NYS wrapper, IT-2
      end

      def calculate_line_73
        0 # TODO: Computed from W-2 forms and their NYS wrapper, IT-2
      end

      def calculate_line_76
        result = 0
        (63..75).each do |line_num|
          result += line_or_zero("AMT_#{line_num}")
        end
        result += line_or_zero("AMT_69A")
        result
      end

      def calculate_line_77
        [line_or_zero(:AMT_76) - line_or_zero(:AMT_62), 0].max
      end

      def calculate_line_78
        line_or_zero(:AMT_77)
      end

      def calculate_line_78b
        line_or_zero(:AMT_78)
      end

      def calculate_line_80
        [line_or_zero(:AMT_62) - line_or_zero(:AMT_76), 0].max
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
              row.new(0, 21600, 0, 0.03078),
              row.new(21600, 45000, 665, 0.03762),
              row.new(45000, 90000, 1545, 0.03819),
              row.new(90000, 0, 3264, 0.03876)
            ]
          else
            [
              [0, 12000, 0, 0.03078],
              [12000, 25000, 369, 0.03762],
              [25000, 50000, 858, 0.03819],
              [50000, 0, 1813, 0.03876]
            ]
          end

        table_row = table.reverse.find do |table_row|
          amount > table_row.floor && (amount <= table_row.ceiling)
        end

        (table_row.cumulative + ((amount - table_row.floor) * table_row.rate)).round
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
        if filing_status_mfj?
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

      def full_year_nyc_resident?
        # TODO: F_1_NBR needs to be passed in
        if filing_status_mfj?
          if @lines["F_1_NBR"]&.value == 12 && @lines["F_2_NBR"]&.value == 12
            true
          end
        else
          @lines["F_1_NBR"]&.value == 12
        end
      end

      def filing_status_hoh?
        @filing_status == :head_of_household
      end

      def filing_status_mfj?
        @filing_status == :married_filing_jointly
      end

      def filing_status_single?
        @filing_status == :single
      end

      def line_or_zero(line)
        @lines[line.to_sym]&.value || 0
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
        # TODO: What if amount is negative?
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
