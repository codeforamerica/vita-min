module StateFile
  module ArchivedIntakes
    class VerificationCodeController < ArchivedIntakeController
      before_action :check_feature_flag
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
          create_state_file_access_log(1)

          redirect_to root_path
        else
          create_state_file_access_log(2)
          current_request.increment!(:failed_attempts)

          if current_request.failed_attempts > 1
            create_state_file_access_log(6)
            current_request.lock_access!
            redirect_to root_path
            return
          end
          render :edit
        end
      end

      private

      def verification_code_form_params
        params.require(:state_file_archived_intakes_verification_code_form).permit(:verification_code)
      end

      def check_feature_flag
        unless Flipper.enabled?(:get_your_pdf)
          redirect_to root_path
        end
      end
    end
  end
end
