require 'csv'

module StateFile
  module ArchivedIntakes
    class MailingAddressValidationController < ArchivedIntakeController
      before_action :check_feature_flag
      before_action :is_request_locked
      before_action :confirm_code_and_ssn_verification
      def edit
        create_state_file_access_log("issued_mailing_address_challenge")
        @addresses = current_request.address_challenge_set
        @form = MailingAddressValidationForm.new(addresses: @addresses, current_address: current_archived_intake.full_address)
      end

      def update
        @form = MailingAddressValidationForm.new(mailing_address_validation_form_params, addresses: @addresses, current_address: current_archived_intake.full_address)
        @addresses = current_request.address_challenge_set

        if @form.valid?
          create_state_file_access_log("correct_mailing_address")
          session[:mailing_verified] = true
          # TODO: https://codeforamerica.atlassian.net/browse/FYST-1520
          # need to change to download path
          redirect_to root_path
        elsif params["state_file_archived_intakes_mailing_address_validation_form"].present?
          create_state_file_access_log("incorrect_mailing_address")
          current_request.lock_access!
          redirect_to state_file_archived_intakes_verification_error_path
        else
          render :edit
        end
      end

      private

      def confirm_code_and_ssn_verification
        unless session[:code_verified] && session[:ssn_verified]
          create_state_file_access_log("unauthorized_mailing_attempt")
          redirect_to root_path
        end
      end

      def mailing_address_validation_form_params
        params.fetch(:state_file_archived_intakes_mailing_address_validation_form, {}).permit(:selected_address)
      end
    end
  end
end
