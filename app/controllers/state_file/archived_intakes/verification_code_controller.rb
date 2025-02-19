module StateFile
  module ArchivedIntakes
    class VerificationCodeController < ArchivedIntakeController
      before_action :check_feature_flag
      before_action :is_request_locked
      def edit
        @form = VerificationCodeForm.new(email_address: current_request.email_address)
        @email_address = current_request.email_address
        ArchivedIntakeEmailVerificationCodeJob.perform_later(
          email_address: @email_address,
          locale: I18n.locale
        )
      end

      def update
        @form = VerificationCodeForm.new(verification_code_form_params, email_address: current_request.email_address)
        @email_address = current_request.email_address

        if @form.valid?
          create_state_file_access_log("correct_email_code")
          create_state_file_access_log("issued_ssn_challenge")
          current_request.reset_failed_attempts!
          session[:code_verified] = true
          redirect_to state_file_archived_intakes_edit_identification_number_path
        else
          create_state_file_access_log("incorrect_email_code")
          current_request.increment_failed_attempts
          if current_request.access_locked?
            create_state_file_access_log("client_lockout_begin")
            redirect_to state_file_archived_intakes_verification_error_path
            return
          end
          render :edit
        end
      end

      private

      def verification_code_form_params
        params.require(:state_file_archived_intakes_verification_code_form).permit(:verification_code)
      end
    end
  end
end
