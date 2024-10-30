module Efile
  module Id
    class Id40Calculator < ::Efile::TaxCalculator
      attr_reader :lines

      def initialize(year:, intake:, include_source: false)
        super
        @id39r = Efile::Id::Id39RCalculator.new(
          value_access_tracker: @value_access_tracker,
          lines: @lines,
          intake: @intake
        )
      end

      def calculate
        set_line(:ID40_LINE_6A, :calculate_line_6a)
        set_line(:ID40_LINE_6B, :calculate_line_6b)
        set_line(:ID40_LINE_6C, :calculate_line_6c)
        set_line(:ID40_LINE_6D, :calculate_line_6d)
        set_line(:ID40_LINE_29, :calculate_line_29)
        set_line(:ID40_LINE_43_WORKSHEET, :calculate_grocery_credit)
        set_line(:ID40_LINE_43_DONATE, :calculate_line_43_donate)
        set_line(:ID40_LINE_43, :calculate_line_43)
        @id39r.calculate
        @lines.transform_values(&:value)
      end

      def refund_or_owed_amount
        0
      end

      def grocery_credit_amount
        line_or_zero(:ID40_LINE_43_WORKSHEET)
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

      def grocery_credit_for_household_member(ineligible_months, credit_per_month)
        (12 - ineligible_months) * credit_per_month
      end

      def calculate_grocery_credit
        return 0 if @intake.direct_file_data.claimed_as_dependent?

        credit = 0

        credit += grocery_credit_for_household_member(
          @intake.primary_has_grocery_credit_ineligible_months_yes? ? @intake.primary_months_ineligible_for_grocery_credit : 0,
          @intake.primary_senior? ? 11.67 : 10)

        if filing_status_mfj?
          credit += grocery_credit_for_household_member(
            @intake.spouse_has_grocery_credit_ineligible_months_yes? ? @intake.spouse_months_ineligible_for_grocery_credit : 0,
            @intake.spouse_senior? ? 11.67 : 10)
        end

        @intake.dependents.each do |dependent|
          credit += grocery_credit_for_household_member(
            dependent.id_has_grocery_credit_ineligible_months_yes? ? dependent.id_months_ineligible_for_grocery_credit : 0,
            10)
        end

        credit.round
      end

      def calculate_line_43_donate
        @intake.donate_grocery_credit_yes?
      end

      def calculate_line_43
        @lines[:ID40_LINE_43_DONATE]&.value ? 0 : line_or_zero(:ID40_LINE_43_WORKSHEET)
      end
    end
  end
end
