module StateFile
  module Questions
    class NcTaxesOwedController < QuestionsController
      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.negative? # what happens if zero?
      end

      def taxes_owed
        current_intake.calculated_refund_or_owed_amount.abs
      end

      def self.form_key
        "state_file/taxes_owed_form"
      end
      helper_method :taxes_owed

      private

      def card_postscript; end
    end
  end
end
