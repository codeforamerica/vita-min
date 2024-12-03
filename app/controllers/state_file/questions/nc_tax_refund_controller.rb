module StateFile
  module Questions
    class NcTaxRefundController < QuestionsController
      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.positive?
      end

      def refund_amount
        current_intake.calculated_refund_or_owed_amount
      end

      def self.form_key
        "state_file/tax_refund_form"
      end

      helper_method :refund_amount


      private

      def card_postscript; end
    end
  end
end
