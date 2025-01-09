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
          redirect_to root_path
        else
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
