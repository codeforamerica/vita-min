module StateFile
  module Questions
    class NjReviewController < BaseReviewController
      before_action :get_detailed_return_info

      def get_detailed_return_info
        @detailed_return_info = [
          [
            { text_key: '15_wages_salaries_tips', value: line_or_zero(:NJ1040_LINE_15) },
            { text_key: '16a_interest_income', value: line_or_zero(:NJ1040_LINE_16A) },
            # { text_key: '20a_retirement_income', value: line_or_zero(:NJ1040_LINE_20A) },
            { text_key: '27_total_income', value: line_or_zero(:NJ1040_LINE_27) },
            # { text_key: '28c_retirement_excluded_from_taxation', value: line_or_zero(:NJ1040_LINE_28C) },
            { text_key: '29_nj_gross_income', value: line_or_zero(:NJ1040_LINE_29) },
            { text_key: '30_exemptions', value: line_or_zero(:NJ1040_LINE_13) }, # same value for 13 and 30
            { text_key: '31_medical', value: line_or_zero(:NJ1040_LINE_31) },
            { text_key: '41_property', value: line_or_zero(:NJ1040_LINE_41) },
            { text_key: '42_nj_taxable', value: line_or_zero(:NJ1040_LINE_42) },
          ],
          [
            { text_key: '43_income_tax', value: line_or_zero(:NJ1040_LINE_43) },
            { text_key: '51_use_tax', value: line_or_zero(:NJ1040_LINE_51) },
            { text_key: '54_total_tax', value: line_or_zero(:NJ1040_LINE_54) },
          ],
          [
            { text_key: '55_tax_withheld', value: line_or_zero(:NJ1040_LINE_55) },
            { text_key: '56_property_tax_credit', value: line_or_zero(:NJ1040_LINE_56) },
            { text_key: '58_nj_eitc', value: line_or_zero(:NJ1040_LINE_58) },
            { text_key: '59_excess_uiwfswf', value: line_or_zero(:NJ1040_LINE_59) },
            { text_key: '61_excess_fli', value: line_or_zero(:NJ1040_LINE_61) },
            { text_key: '64_child_dep_care', value: line_or_zero(:NJ1040_LINE_64) },
            { text_key: '65_nj_ctc', value: line_or_zero(:NJ1040_LINE_65) },
            { text_key: '66_total_payments_refundable_credits', value: line_or_zero(:NJ1040_LINE_66) },
          ]
        ]
      end

      def line_or_zero(line)
        @calculated_fields ||= current_intake.tax_calculator.calculate
        @calculated_fields.fetch(line) || 0
      end
    end
  end
end
