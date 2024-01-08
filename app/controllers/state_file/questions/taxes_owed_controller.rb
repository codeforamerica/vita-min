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
        case params[:us_state]
        when "ny"
          'https://www.tax.ny.gov/pay/ind/pay-income-tax-online.htm'
        when 'az'
          'https://azdor.gov/making-payments-late-payments-and-filing-extensions'
        else
          ''
        end
      end
      helper_method :pay_mail_online_link

      def pay_mail_online_text
        case params[:us_state]
        when "ny"
          'Tax.NY.gov'
        when 'az'
          'AZTaxes.gov'
        else
          ''
        end
      end
      helper_method :pay_mail_online_text


      private

      def card_postscript; end

    end
  end
end
