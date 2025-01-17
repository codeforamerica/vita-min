module StateFile
  module ArchivedIntakes
    class IdentificationNumberController < ArchivedIntakeController
      before_action :confirm_code_verification
      before_action :is_request_locked

      def edit
        @form = IdentificationNumberForm.new(archived_intake_request: current_request)
        render :edit
      end

      def update
        @form = IdentificationNumberForm.new(current_request, identification_number_form_params)

        if @form.valid?
          create_state_file_access_log("correct_ssn_challenge")
          current_request.reset_failed_attempts!
          session[:ssn_verified] = true
          redirect_to root_path
          # need to change to address controller
        else
          create_state_file_access_log("incorrect_ssn_challenge")
          current_request.increment_failed_attempts
          if current_request.access_locked?
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

      def is_request_locked
        if current_request.access_locked?
          redirect_to state_file_archived_intakes_verification_error_path
        end
      end
    end
  end
end
