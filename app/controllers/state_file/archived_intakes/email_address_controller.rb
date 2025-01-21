module StateFile
  module ArchivedIntakes
    class EmailAddressController < ArchivedIntakeController
      before_action :check_feature_flag

      before_action :log_ip_prospects

      def log_ip_prospects
        puts "request.remote_ip: #{request.remote_ip}"
        puts "all headers:"
        request.headers.each { |k, v| puts "  #{k}: #{v}" }
      end

      def edit
        @form = EmailAddressForm.new
      end

      def update
        @form = EmailAddressForm.new(email_address_form_params)

        if @form.valid?
          archived_intake = StateFileArchivedIntake.find_by(email_address: @form.email_address)
          # Make sure we reference the new request (ex: request.email_address) to ensure we have a current_request on the next page in cases where db operations run slowly (i.e. demo)
          request = StateFileArchivedIntakeRequest.find_or_create_by(email_address: @form.email_address, ip_address: ip_for_irs, state_file_archived_intake_id: archived_intake&.id)
          session[:email_address] = request.email_address
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
