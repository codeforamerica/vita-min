module Efile
  module Ny
    class It214 < ::Efile::TaxCalculator
      attr_reader :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = intake.direct_file_data
        @intake = intake
      end

      def calculate
        set_line(:IT214_LINE_1, -> { 1 })
        set_line(:IT214_LINE_2, @intake, :occupied_residence)
        if @lines[:IT214_LINE_2].value == 2
          offboard
          return
        end
        set_line(:IT214_LINE_3, @intake, :property_over_limit)
        if @lines[:IT214_LINE_3].value == 1
          offboard
          return
        end
        # Todo: Dependent on federal return?
        set_line(:IT214_LINE_4, -> { 2 })
        if false #todo: if value is 1 then offboard
          offboard
          return
        end
        set_line(:IT214_LINE_5, @intake, :public_housing)
        if @lines[:IT214_LINE_5].value == 1
          offboard
          return
        end
        set_line(:IT214_LINE_6, @intake, :nursing_home)
        if @lines[:IT214_LINE_6].value == 1
          offboard
          return
        end
        set_line(:IT214_LINE_9, @direct_file_data, :fed_agi) # TODO Need to add additional household members deductions if applicable
        set_line(:IT214_LINE_10, -> { @lines[:IT201_LINE_24].value }) # TODO Need to add additional household members deductions if applicable
        set_line(:IT214_LINE_11, @direct_file_data, :fed_non_taxable_ssb)
        set_line(:IT214_LINE_12, @intake, :household_ssi)
        set_line(:IT214_LINE_13, -> { 0 })
        set_line(:IT214_LINE_14, @intake, :household_cash_assistance)
        set_line(:IT214_LINE_15, @intake, :household_other_income)
        set_line(:IT214_LINE_16, :calculate_line_16)
        if @lines[:IT214_LINE_16].value > 18000
          offboard
          return
        end
        set_line(:IT214_LINE_17, :calculate_line_17)
        set_line(:IT214_LINE_18, :calculate_line_18)
        if @intake.household_rent_own_rent?
          set_line(:IT214_LINE_19,  @intake, :household_rent_amount)
          set_line(:IT214_LINE_20,  @intake, :household_rent_adjustments)
          set_line(:IT214_LINE_21, :calculate_line_21)
          if @lines[:IT214_LINE_21].value > 450
            offboard
            return
          end
          set_line(:IT214_LINE_22, :calculate_line_22)
          set_line(:IT214_LINE_28, -> {@lines[:IT214_LINE_22].value })
        elsif @intake.household_rent_own_own?
          set_line(:IT214_LINE_23, @intake, :household_own_propety_tax)
          set_line(:IT214_LINE_24, @intake, :household_own_assessments)
          set_line(:IT214_LINE_25, :calculate_line_25)
          set_line(:IT214_LINE_27, -> {@lines[:IT214_LINE_25].value })
          set_line(:IT214_LINE_28, -> {@lines[:IT214_LINE_27].value })
        end
        if @lines[:IT214_LINE_28].value <= 0
          offboard
          return
        end
        set_line(:IT214_LINE_29, -> {@lines[:IT214_LINE_18].value })
        if @lines[:IT214_LINE_29].value >= @lines[:IT214_LINE_28].value
          offboard
          return
        end
        set_line(:IT214_LINE_30, :calculate_line_30)
        set_line(:IT214_LINE_31, :calculate_line_31)
        set_line(:IT214_LINE_32, :calculate_line_32)
        set_line(:IT214_LINE_33, :calculate_line_33)
      end

      private

      def offboard
        set_line(:IT214_LINE_33, -> { 0 })
      end

      def calculate_line_16
        result = 0
        (9..15).each do |line_num|
          result += line_or_zero("IT214_LINE_#{line_num}")
        end
        result
      end

      def calculate_line_17
        rates = [
          [-Float::INFINITY, 3000, 0.035],
          [3001, 5000, 0.040],
          [5001, 7000, 0.045],
          [7001, 9000, 0.050],
          [9001, 11000, 0.055],
          [11001, 14000, 0.060],
          [14001, 18000, 0.065],
        ]
        l16_value = @lines[:IT214_LINE_16].value
        row = rates.find { |row| l16_value >= row[0] && l16_value <= row[1] }
        row[2]
      end

      def calculate_line_18
        (@lines[:IT214_LINE_16].value * @lines[:IT214_LINE_17].value).round
      end

      def calculate_line_21
        months_paid_rent = 12 # TODO: collect from intake someday
        (@lines[:IT214_LINE_20].value / months_paid_rent.to_f).round
      end

      def calculate_line_22
        (@lines[:IT214_LINE_20].value * 0.25).round
      end

      def calculate_line_25
        @lines[:IT214_LINE_23].value + @lines[:IT214_LINE_24].value
      end

      def calculate_line_30
        @lines[:IT214_LINE_28].value - @lines[:IT214_LINE_29].value
      end

      def calculate_line_31
        (@lines[:IT214_LINE_30].value * 0.5).round
      end

      def calculate_line_32
        rows = [
          [-Float::INFINITY, 1000, 375, 75],
          [1001, 2000, 358, 73],
          [2001, 3000, 341, 71],
          [3001, 4000, 324, 69],
          [4001, 5000, 307, 67],
          [5001, 6000, 290, 65],
          [6001, 7000, 273, 63],
          [7001, 8000, 256, 61],
          [8001, 9000, 239, 59],
          [9001, 10000, 222, 57],
          [10001, 11000, 205, 55],
          [11001, 12000, 188, 53],
          [12001, 13000, 171, 51],
          [13001, 14000, 154, 49],
          [14001, 15000, 137, 47],
          [15001, 16000, 120, 45],
          [16001, 17000, 103, 43],
          [17001, 18000, 86, 41],
        ]
        l16_value = @lines[:IT214_LINE_16].value
        row = rows.find { |row| l16_value >= row[0] && l16_value <= row[1] }
        row[3] # TODO need to set value to column row[2] if we use line 7
      end

      def calculate_line_33
        [@lines[:IT214_LINE_31].value, @lines[:IT214_LINE_32].value].min
      end
    end
  end
end
