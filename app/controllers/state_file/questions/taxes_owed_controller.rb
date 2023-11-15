module StateFile
  module Questions
    class TaxesOwedController < QuestionsController

      def taxes_owed
        calculator = current_intake.tax_calculator
        calculator.calculate
        calculator.refund_or_owed_amount
      end
      helper_method :taxes_owed

      def pay_mail_online_link
        case params[:us_state]
        when "ny"
          'https://www.tax.ny.gov/'
        when 'az'
          'https://www.aztaxes.gov/Home/PaymentIndividual/'
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

      def prev_path
        prev_path = StateFile::Questions::AzReviewController
        options = { us_state: params[:us_state], action: prev_path.navigation_actions.first }
        prev_path.to_path_helper(options)
      end
    end
  end
end
