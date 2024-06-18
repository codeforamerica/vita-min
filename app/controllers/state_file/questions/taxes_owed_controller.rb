module StateFile
  module Questions
    class TaxesOwedController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.calculated_refund_or_owed_amount.negative? # what happens if zero?
      end

      def taxes_owed
        current_intake.calculated_refund_or_owed_amount.abs
      end
      helper_method :taxes_owed

      def pay_mail_online_link
        StateFile::StateInformationService.pay_mail_online_link(current_state_code)
      end
      helper_method :pay_mail_online_link

      def pay_mail_online_text
        StateFile::StateInformationService.tax_payment_url(current_state_code)
      end
      helper_method :pay_mail_online_text

      private

      def card_postscript; end
    end
  end
end
