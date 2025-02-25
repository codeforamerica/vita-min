module StateFile
  module ArchivedIntakes
    class EmailAddressController < ArchivedIntakeController
      before_action :check_feature_flag
      def edit
        @form = EmailAddressForm.new
      end

      def update
        @form = EmailAddressForm.new(email_address_form_params)

        if @form.valid?
          session[:email_address] = @form.email_address
          create_state_file_access_log("issued_email_challenge")

          redirect_to state_file_archived_intakes_edit_verification_code_path
        else
          render :edit
        end
      end

      private

      def email_address_form_params
        params.require(:state_file_archived_intakes_email_address_form).permit(:email_address)
      end
    end
  end
end
