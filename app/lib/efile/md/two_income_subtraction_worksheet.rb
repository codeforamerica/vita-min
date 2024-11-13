module Efile
  module Md
    class TwoIncomeSubtractionWorksheet < ::Efile::TaxCalculator
      # https://www.marylandtaxes.gov/forms/worksheets/Two-income-worksheet.pdf

      attr_accessor :lines, :value_access_tracker

      def initialize(value_access_tracker:, lines:, intake:)
        @value_access_tracker = value_access_tracker
        @lines = lines
        @intake = intake
        @direct_file_data = intake.direct_file_data
        @direct_file_json_data = intake.direct_file_json_data
      end

      def calculate
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_PRIMARY, -> { calculate_line_1 :primary })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_PRIMARY, -> { calculate_line_2 :primary })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_PRIMARY, -> { calculate_line_3 :primary })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_PRIMARY, -> { calculate_line_4 :primary })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY, -> { calculate_line_5 :primary })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_SPOUSE, -> { calculate_line_1 :spouse })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_SPOUSE, -> { calculate_line_2 :spouse })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_SPOUSE, -> { calculate_line_3 :spouse })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_SPOUSE, -> { calculate_line_4 :spouse })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_SPOUSE, -> { calculate_line_5 :spouse })
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_6, :calculate_line_6)
        set_line(:MD_TWO_INCOME_SUBTRACTION_WK_LINE_7, :calculate_line_7)
      end

      def calculate_fed_income(primary_or_spouse)
        filer = @intake.send(primary_or_spouse)

        wage_income = @intake.state_file_w2s
                             .select { |w2| w2.employee_ssn == filer.ssn }
                             .sum(&:state_income_tax_amount)
        interest_income = @direct_file_json_data.interest_reports
                                                .select { |interest_report| interest_report.recipient_tin == filer.ssn }
                                                .sum { |interest_report|
                                                  interest_report.amount_1099 + interest_report.amount_no_1099
                                                }
        retirement_income = @intake.state_file1099_rs
                                   .select { |form1099r| form1099r.recipient_ssn == filer.ssn }
                                   .sum(&:taxable_amount)
        # TODO: check in about getting this from DF JSON instead
        unemployment_income = @intake.state_file1099_gs
                                     .select { |form1099g| form1099g.recipient == primary_or_spouse }
                                     .sum(&:unemployment_compensation_amount)

        wage_income +
          interest_income +
          retirement_income +
          unemployment_income
      end

      def calculate_fed_subtractions(primary_or_spouse)
        filer_json = @direct_file_json_data.filers
                                           .select { |df_filer_data|
                                             df_filer_data.tin == @intake.send(primary_or_spouse).ssn
                                           }
        student_loan_interest = {
          primary: 0, # TBD primary_student_loan_interest_ded_amount
          spouse: 0, # TBD spouse_student_loan_interest_ded_amount
        }[primary_or_spouse]
        educator_expenses = 0 # TODO: filer_json.educatorExpenses
        hsa_deduction = 0 # TODO: filer_json.hsaTotalDeductibleAmount

        student_loan_interest +
          educator_expenses +
          hsa_deduction
      end

      private

      def calculate_line_1(primary_or_spouse)
        calculate_fed_income(primary_or_spouse) - calculate_fed_subtractions(primary_or_spouse)
      end

      def calculate_line_2(primary_or_spouse)
        @intake.state_file_w2s
               .select { |w2| w2.employee_ssn == @intake.send(primary_or_spouse).ssn }
               .sum(&:box14_stpickup)
      end

      def calculate_line_3(primary_or_spouse)
        if primary_or_spouse
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_PRIMARY].value +
            @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_PRIMARY].value
        else
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_1_SPOUSE].value +
            @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_2_SPOUSE].value
        end
      end

      def calculate_line_4(primary_or_spouse)
        cdc_expenses = @direct_file_data.total_qualifying_dependent_care_expenses / 2
        pension_exclusion = 0 # TODO: MD pension exclusion
        military_retirement_exclusion = 0 # TODO: MD military retirement exclusion

        cdc_expenses +
          pension_exclusion +
          military_retirement_exclusion
      end

      def calculate_line_5(primary_or_spouse)
        if primary_or_spouse
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_PRIMARY].value -
            @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_PRIMARY].value
        else
          @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_3_SPOUSE].value -
            @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_4_SPOUSE].value
        end
      end

      def calculate_line_6
        lower_income = [@lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY].value,
                        @lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_SPOUSE].value].min
        [lower_income, 0].max
      end

      def calculate_line_7
        [@lines[:MD_TWO_INCOME_SUBTRACTION_WK_LINE_5_PRIMARY].value, 1_200].max
      end
    end
  end
end
