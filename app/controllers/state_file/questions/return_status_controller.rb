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
        @download_form_name = download_form_name
        @mail_voucher_address = mail_voucher_address
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
        # current_intake.return_status
        'accepted'
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

      def download_form_name
        case params[:us_state]
        when 'ny'
          'Form IT-201-V'
        when 'az'
          'Form AZ-140V'
        else
          ''
        end
      end

      def mail_voucher_address
        case params[:us_state]
        when 'ny'
          "NYS Personal Income Tax<br/>"\
          "Processing Center<br/>"\
          "Box 4124<br/>"\
          "Binghamton, NY 13902-4124".html_safe
        when 'az'
          "Arizona Department of Revenue<br/>"\
          "PO Box 29085<br/>"\
          "Phoenix, AZ 85038-9085".html_safe
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
