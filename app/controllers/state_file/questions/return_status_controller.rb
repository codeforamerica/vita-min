module StateFile
  module Questions
    class ReturnStatusController < AuthenticatedQuestionsController
      before_action :redirect_if_from_efile
      before_action :redirect_if_no_submission

      def edit
        @error = submission_error
        @return_status = return_status
        @refund_url = refund_url
        @tax_payment_url = tax_payment_url
        @download_form_name = download_form_name
        @mail_voucher_address = mail_voucher_address
        @voucher_path = voucher_path
      end

      def prev_path
        nil
      end

      private

      def submission_error
        return nil unless return_status == 'rejected'
        # in the case that its in the notified_of_rejection or waiting state
        # we can't just grab the efile errors from the last transition
        current_intake.latest_submission&.efile_submission_transitions&.where(to_state: 'rejected')&.last&.efile_errors&.last
      end

      def return_status
        # return status for display
        case current_intake.latest_submission.current_state
        when 'accepted'
          'accepted'
        when 'notified_of_rejection', 'waiting'
          'rejected'
        else
          'pending'
        end
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

      def voucher_path
        case params[:us_state]
        when 'ny'
          '/pdfs/it201v_1223.pdf'
        when 'az'
          '/pdfs/AZ-140V.pdf'
        else
          ''
        end
      end

      def card_postscript; end

      def redirect_if_no_submission
        if current_intake.efile_submissions.empty?
          redirect_to StateFile::Questions::InitiateDataTransferController.to_path_helper(us_state: state_code)
        end
      end

      def redirect_if_from_efile
        # We had a situation where we gave the wrong URL to direct file, and they were redirecting
        # here when the federal return was not yet approved.
        # We have alerted them, and once they have updated their URL we can probably remove this
        if params[:ref_location] == "df_authorize_state"
          redirect_to StateFile::Questions::PendingFederalReturnController.to_path_helper(us_state: current_intake.state_code)
        end
      end

    end
  end
end
