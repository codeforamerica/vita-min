module StateFile
  module ArchivedIntakes
    class VerificationCodeController < ApplicationController
      def edit
        @form = VerificationCodeForm.new
        @email_address = params[:email_address]
        RequestVerificationCodeEmailJob.perform_later(
          email_address: @email_address,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end

      def update
        @form = VerificationCodeForm.new(verification_code_form_params)

        if @form.save
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
