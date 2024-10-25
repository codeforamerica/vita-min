module Efile
  module Id
    class Id40Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
      end

      def calculate
        set_line(:ID40_LINE_6A, :calculate_line_6a)
        set_line(:ID40_LINE_6B, :calculate_line_6b)
        set_line(:ID40_LINE_6C, :calculate_line_6c)
        set_line(:ID40_LINE_6D, :calculate_line_6d)
        set_line(:ID40_LINE_29, :calculate_line_29)

        set_line(:ID40_LINE_43, :calculate_line_43)
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def analytics_attrs
        {}
      end

      private

      def calculate_line_6a
        @direct_file_data.claimed_as_dependent? ? 0 : 1
      end

      def calculate_line_6b
        (@intake.filing_status_mfj? && !@direct_file_data.spouse_is_a_dependent?) ? 1 : 0
      end

      def calculate_line_6c
        @intake.dependents.count
      end

      def calculate_line_6d
        line_or_zero(:ID40_LINE_6A) + line_or_zero(:ID40_LINE_6B) + line_or_zero(:ID40_LINE_6C)
      end

      def calculate_line_29
        if @intake.has_unpaid_sales_use_tax? && !@intake.total_purchase_amount.nil?
          (@intake.total_purchase_amount * 0.06).round
        else
          0
        end
      end

      def calculate_line_43
        return 0 if @intake.direct_file_data.claimed_as_dependent?

        # TODO: what if they check the box for having ineligible months, enter a number of months, then uncheck the box & submit?

        primary_eligible_months = 12 - @intake.primary_months_ineligible_for_grocery_credit
        primary_credit_per_month = @intake.primary.age >= 65 ? 11.67 : 10
        primary_credit = primary_eligible_months * primary_credit_per_month

        spouse_eligible_months = 12 - @intake.spouse_months_ineligible_for_grocery_credit
        spouse_credit_per_month = @intake.spouse.age >= 65 ? 11.67 : 10
        spouse_credit = spouse_eligible_months * spouse_credit_per_month

        dependents_credit = @intake.dependents.sum do |dependent|
          dependent_eligible_months = 12 - dependent.id_months_ineligible_for_grocery_credit
          dependent_credit_per_month = 10
          dependent_eligible_months * dependent_credit_per_month
        end

        (primary_credit + spouse_credit + dependents_credit).round
      end
    end
  end
end
