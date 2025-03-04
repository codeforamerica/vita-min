module StateFile
  module ArchivedIntakes
    class IdentificationNumberController < ArchivedIntakeController
      before_action :confirm_code_verification
      before_action :is_intake_locked

      def edit
        @form = IdentificationNumberForm.new(archived_intake: current_archived_intake)
        render :edit
      end

      def update
        @form = IdentificationNumberForm.new(current_archived_intake, identification_number_form_params)

        if @form.valid?
          create_state_file_access_log("correct_ssn_challenge")
          current_archived_intake.reset_failed_attempts!
          session[:ssn_verified] = true
          redirect_to state_file_archived_intakes_edit_mailing_address_validation_path
        else
          create_state_file_access_log("incorrect_ssn_challenge")
          current_archived_intake.increment_failed_attempts
          if current_archived_intake.access_locked?
            create_state_file_access_log("client_lockout_begin")
            redirect_to state_file_archived_intakes_verification_error_path
            return
          end
          render :edit
        end
      end

      def identification_number_form_params
        params.require(:state_file_archived_intakes_identification_number_form).permit(:ssn)
      end

      def confirm_code_verification
        unless session[:code_verified]
          create_state_file_access_log("unauthorized_ssn_attempt")
          redirect_to root_path
        end
      end
    end
  end
end
