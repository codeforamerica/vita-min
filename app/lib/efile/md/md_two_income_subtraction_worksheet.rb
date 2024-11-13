module Efile
  module Md
    class MdTwoIncomeSubtractionWorksheet < ::Efile::TaxCalculator
      # https://www.marylandtaxes.gov/forms/worksheets/Two-income-worksheet.pdf

      attr_accessor :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @direct_file_data = intake.direct_file_data
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_PRIMARY, -> { calculate_line_1 is_primary_filer: true })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_PRIMARY, -> { calculate_line_2 is_primary_filer: true })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_PRIMARY, -> { calculate_line_3 is_primary_filer: true })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_PRIMARY, -> { calculate_line_4 is_primary_filer: true })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY, -> { calculate_line_5 is_primary_filer: true })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_SPOUSE, -> { calculate_line_1 is_primary_filer: false })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_SPOUSE, -> { calculate_line_2 is_primary_filer: false })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_SPOUSE, -> { calculate_line_3 is_primary_filer: false })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_SPOUSE, -> { calculate_line_4 is_primary_filer: false })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_SPOUSE, -> { calculate_line_5 is_primary_filer: false })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_6, :calculate_line_6)
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_7, :calculate_line_7)
      end

      private

      def calculate_fed_income(is_primary_filer:)
        # NOTE: this is only income relevant for this worksheet and current tax scope

        # direct_file_data.w2s.WagesAmt / direct_file_data.w2s.EmployeeSSN
        # direct_file_json_data.interest_reports.amount_1099 / direct_file_json_data.interest_reports.recipient_tin
        # direct_file_json_data.interest_reports.amount_no_1099 / direct_file_json_data.interest_reports.recipient_tin
        # state_file1099_rs.taxable_amount / intake_class.state_file1099_rs.recipient_ssn
        # direct_file_json_data.filers.form1099GsTotal / direct_file_json_data.filers.tin OR something else?
        is_primary_filer
        0
      end

      def calculate_fed_subtractions(is_primary_filer:)
        # subtractions
        # STUB: primary_student_loan_interest_ded_amount & spouse_student_loan_interest_ded_amount
        # direct_file_json_data.filers.educatorExpenses
        # direct_file_json_data.filers.hsaTotalDeductibleAmount
        is_primary_filer
        0
      end

      def calculate_line_1(is_primary_filer:)
        calculate_fed_income(is_primary_filer: is_primary_filer) - calculate_fed_subtractions(is_primary_filer: is_primary_filer)
      end

      def calculate_line_2(is_primary_filer:)
        # intake_class.state_file_w2s.box_14_stpickup / intake_class.state_file_w2s.employee_ssn
        0
      end

      def calculate_line_3(is_primary_filer:)
        if is_primary_filer
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_PRIMARY].value + @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_PRIMARY].value
        else
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_SPOUSE].value + @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_SPOUSE].value
        end
      end

      def calculate_line_4(is_primary_filer:)
        # direct_file_data.total_qualifying_dependent_care_expenses / 2
        # STUB: MD pension exclusion
        # STUB: MD retirement exclusion
        0
      end

      def calculate_line_5(is_primary_filer:)
        if is_primary_filer
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_PRIMARY].value - @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_PRIMARY].value
        else
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_SPOUSE].value - @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_SPOUSE].value
        end
      end

      def calculate_line_6
        lower_income = [@lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY].value, @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_SPOUSE].value].min
        [lower_income, 0].max
      end

      def calculate_line_7
        [@lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY].value, 1_200].max
      end
    end
  end
end
