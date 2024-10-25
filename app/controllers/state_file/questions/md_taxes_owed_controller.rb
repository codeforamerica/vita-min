module StateFile
  module Questions
    class MdTaxesOwedController < QuestionsController
      def self.show?(intake)
        true
        # intake.calculated_refund_or_owed_amount.negative? # what happens if zero?
      end

      def taxes_owed
        current_intake.calculated_refund_or_owed_amount.abs
      end
      helper_method :taxes_owed

      private

      def card_postscript; end
    end
  end
end
