module StateFile
  module Questions
    class ReturnStatusController < QuestionsController
      before_action :redirect_if_no_submission
      skip_before_action :redirect_if_in_progress_intakes_ended

      def edit
        @submission_to_show = current_intake.latest_submission
        @return_status = return_status
        @error = submission_error
        @tax_refund_url = StateFile::StateInformationService.tax_refund_url(current_state_code)
        @tax_payment_url = StateFile::StateInformationService.tax_payment_url(current_state_code)
        @voucher_form_name = StateFile::StateInformationService.voucher_form_name(current_state_code)
        @mail_voucher_address = StateFile::StateInformationService.mail_voucher_address(current_state_code)
        @voucher_path = StateFile::StateInformationService.voucher_path(current_state_code)
        @survey_link = StateFile::StateInformationService.survey_link(current_state_code)
      end

      def prev_path
        nil
      end

      private

      def submission_error
        return nil unless return_status == 'rejected'
        # in the case that its in the notified_of_rejection or waiting state
        # we can't just grab the efile errors from the last transition
        @submission_to_show&.efile_submission_transitions&.where(to_state: 'rejected')&.last&.efile_errors&.last
      end

      def return_status
        # return status for display
        case @submission_to_show.current_state
        when 'accepted'
          'accepted'
        when 'notified_of_rejection', 'waiting'
          'rejected'
        else
          'pending'
        end
      end

      def card_postscript; end

      def redirect_if_no_submission
        if current_intake.efile_submissions.empty?
          redirect_to StateFile::Questions::InitiateDataTransferController.to_path_helper
        end
      end
    end
  end
end
