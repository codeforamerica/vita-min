module StateFile
  module ArchivedIntakes
    class VerificationCodeController < ArchivedIntakeController
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

        if @form.valid?
          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            event_type: 1,
            state_file_archived_intake_request: current_request
          )

          redirect_to root_path
        else
          StateFileArchivedIntakeAccessLog.create!(
            ip_address: ip_for_irs,
            event_type: 2,
            state_file_archived_intake_request: current_request
          )
          current_request.increment!(:failed_attempts)
          if current_request.failed_attempts == 1
            errors.add(:verification_code, "Incorrect verification code. After 2 failed attempts, accounts are locked.")
          elsif current_request.failed_attempts > 1
            StateFileArchivedIntakeAccessLog.create!(
              ip_address: ip_for_irs,
              event_type: 6,
              state_file_archived_intake_request: current_request
            )
            current_request.lock_access!
            redirect_to root_path
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
