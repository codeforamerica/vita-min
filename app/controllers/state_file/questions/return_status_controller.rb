module StateFile
  module Questions
    class ReturnStatusController < AuthenticatedQuestionsController

      def edit
        @title = title
        @return_status = return_status
        @reject_code = reject_code
        @reject_description = reject_description
        @refund_or_owed_amount = refund_or_owed_amount
        @refund_url = refund_url
        @tax_payment_url = tax_payment_url
      end

      private

      def title
        state_name = States.name_for_key(params[:us_state].upcase)
        case return_status
        when 'accepted'
          I18n.t("state_file.questions.return_status.accepted.title", state_name: state_name)
        when 'rejected'
          I18n.t("state_file.questions.return_status.rejected.title", state_name: state_name)
        else
          I18n.t("state_file.questions.return_status.pending.title", state_name: state_name)
        end
      end

      def return_status
        current_intake.return_status
      end

      def refund_or_owed_amount
        current_intake.calculated_refund_or_owed_amount
      end

      def refund_url
        case params[:us_state]
        when 'ny'
          'https://www.tax.ny.gov/pit/file/refund.htm'
        when 'az'
          'https://aztaxes.gov/home/checkrefund'
        else
          ''
        end
      end

      def tax_payment_url
        case params[:us_state]
        when 'ny'
          'Tax.NY.gov'
        when 'az'
          'AZTaxes.gov'
        else
          ''
        end
      end

      def e_file_error
        @error ||= current_intake.efile_submissions.last.last_transition.efile_errors.take
      end

      def reject_code
        e_file_error.try(:code)
      end

      def reject_description
        e_file_error.try(:message)
      end

      private

      def card_postscript; end

    end
  end
end
