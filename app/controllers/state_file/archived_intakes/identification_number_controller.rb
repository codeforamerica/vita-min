# 1. use front end validations for SSN
# 2. give them 1 attempt at an incorrect SSN
# 3. update the access logs to have the correct event
# 4. tests
# 5. translations
# 6. remove the session and use the path to pass the email address
module StateFile
  module ArchivedIntakes
    class IdentificationNumberController < ArchivedIntakeController
      before_action :check_feature_flag
      before_action :confirm_code_verification
      def edit
        archived_intake_request = StateFileArchivedIntakeRequest.find_by(email_address: session[:email_address])
        @form = IdentificationNumberForm.new(archived_intake_request: archived_intake_request)
        render :edit
      end

      def update
        archived_intake_request = StateFileArchivedIntakeRequest.find_by(email_address: session[:email_address])
        @form = IdentificationNumberForm.new(archived_intake_request: archived_intake_request, **identification_number_form_params)

        if @form.valid?
          create_state_file_access_log("correct_ssn_challenge")
          current_request.reset_failed_attempts!
          redirect_to state_file_archived_intakes_edit_identification_number_path
        else
          create_state_file_access_log("incorrect_ssn_challenge")
          current_request.increment_failed_attempts
          if current_request.access_locked?
            create_state_file_access_log("client_lockout_begin")
            # this redirect to be changed when we have an offboarding page
            redirect_to root_path
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
