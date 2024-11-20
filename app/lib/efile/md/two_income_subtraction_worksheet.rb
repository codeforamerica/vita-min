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
        set_line(:MD_TWO_INCOME_WK_LINE_1_A, -> { calculate_line_1 :primary })
        set_line(:MD_TWO_INCOME_WK_LINE_2_A, -> { calculate_line_2 :primary })
        set_line(:MD_TWO_INCOME_WK_LINE_3_A, -> { calculate_line_3 :primary })
        set_line(:MD_TWO_INCOME_WK_LINE_4_A, -> { calculate_line_4 :primary })
        set_line(:MD_TWO_INCOME_WK_LINE_5_A, -> { calculate_line_5 :primary })
        set_line(:MD_TWO_INCOME_WK_LINE_1_B, -> { calculate_line_1 :spouse })
        set_line(:MD_TWO_INCOME_WK_LINE_2_B, -> { calculate_line_2 :spouse })
        set_line(:MD_TWO_INCOME_WK_LINE_3_B, -> { calculate_line_3 :spouse })
        set_line(:MD_TWO_INCOME_WK_LINE_4_B, -> { calculate_line_4 :spouse })
        set_line(:MD_TWO_INCOME_WK_LINE_5_B, -> { calculate_line_5 :spouse })
        set_line(:MD_TWO_INCOME_WK_LINE_6, :calculate_line_6)
        set_line(:MD_TWO_INCOME_WK_LINE_7, :calculate_line_7)
      end

      def calculate_fed_income(primary_or_spouse)
        filer = @intake.send(primary_or_spouse)

        wage_income = @direct_file_data.w2s
                                       .select { |w2| w2.EmployeeSSN == filer.ssn }
                                       .sum(&:WagesAmt)
        interest_income = @direct_file_json_data.interest_reports
                                                .select { |interest_report| interest_report.recipient_tin.delete("-") == filer.ssn }
                                                .sum { |interest_report|
                                                  interest_report.amount_1099.round + interest_report.amount_no_1099.round
                                                }
        retirement_income = @intake.state_file1099_rs
                                   .select { |form1099r| form1099r.recipient_ssn == filer.ssn }
                                   .sum { |form1099r| form1099r.taxable_amount.round }
        # TODO: check in about getting this from DF JSON instead
        unemployment_income = @intake.state_file1099_gs
                                     .select { |form1099g| form1099g.recipient.to_sym == primary_or_spouse }
                                     .sum { |form1099g| form1099g.unemployment_compensation_amount.round }

        wage_income +
          interest_income +
          retirement_income +
          unemployment_income
      end

      def calculate_fed_subtractions(primary_or_spouse)
        filer_json = @direct_file_json_data.filers
                                           .find { |df_filer_data|
                                             df_filer_data.tin.delete("-") == @intake.send(primary_or_spouse).ssn
                                           }
        return 0 unless filer_json # TODO: Some MFJ tests are missing spouse JSON - should not happen in prod

        student_loan_interest = {
          primary: @intake.primary_student_loan_interest_ded_amount&.round,
          spouse: @intake.spouse_student_loan_interest_ded_amount&.round,
        }[primary_or_spouse]
        educator_expenses = filer_json.educator_expenses&.round
        hsa_deduction = filer_json.hsa_total_deductible_amount&.round

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
               .sum { |w2| w2.box14_stpickup&.round || 0 }
      end

      def calculate_line_3(primary_or_spouse)
        if primary_or_spouse == :primary
          @lines[:MD_TWO_INCOME_WK_LINE_1_A].value +
            @lines[:MD_TWO_INCOME_WK_LINE_2_A].value
        else
          @lines[:MD_TWO_INCOME_WK_LINE_1_B].value +
            @lines[:MD_TWO_INCOME_WK_LINE_2_B].value
        end
      end

      def calculate_line_4(primary_or_spouse)
        cdc_expenses = @direct_file_data.total_qualifying_dependent_care_expenses / 2

        # NOTE: Stub alert - this data relies on 1099R followup questions, which have been deprioritized
        pension_exclusion = 0
        military_retirement_exclusion = 0

        cdc_expenses +
          pension_exclusion +
          military_retirement_exclusion
      end

      def calculate_line_5(primary_or_spouse)
        if primary_or_spouse == :primary
          @lines[:MD_TWO_INCOME_WK_LINE_3_A].value -
            @lines[:MD_TWO_INCOME_WK_LINE_4_A].value
        else
          @lines[:MD_TWO_INCOME_WK_LINE_3_B].value -
            @lines[:MD_TWO_INCOME_WK_LINE_4_B].value
        end
      end

      def calculate_line_6
        lower_income = [@lines[:MD_TWO_INCOME_WK_LINE_5_A].value,
                        @lines[:MD_TWO_INCOME_WK_LINE_5_B].value].min
        [lower_income, 0].max
      end

      def calculate_line_7
        @lines[:MD_TWO_INCOME_WK_LINE_6].value.clamp(0, 1_200)
      end
    end
  end
end
