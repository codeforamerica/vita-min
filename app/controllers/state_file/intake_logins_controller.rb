module StateFile
  class IntakeLoginsController < Portal::ClientLoginsController
    before_action :redirect_to_data_review_if_intake_authenticated

    layout "state_file/question"

    def new
      @contact_method = params[:contact_method]
      unless ["email_address", "sms_phone_number"].include?(@contact_method)
        return render "public_pages/page_not_found", status: 404
      end
      super
    end

    private

    def extra_path_params
      [:statefile_az, :statefile_ny].reduce({}) { |hash, type|
        hash[:us_state] = type.to_s.gsub("statefile_", "") if service_type == type
        hash
      }
    end

    def increment_failed_attempts_on_login_records
      model = MultiTenantService.new(service_type).intake_model
      contact_info = params[:portal_verification_code_form][:contact_info]
      @intakes = model.where(email_address: contact_info).or(model.where(phone_number: contact_info))
      @intakes.map(&:increment_failed_attempts)
    end

    def request_login_form_class
      RequestIntakeLoginForm
    end

    def service_type
      case params[:us_state]
      when "az" then :statefile_az
      when "ny" then :statefile_ny
      end
    end

    def redirect_to_data_review_if_intake_authenticated
      redirect_to StateFile::Questions::DataReviewController.to_path_helper(us_state: params[:us_state]) if current_state_file_az_intake.present? || current_state_file_ny_intake.present?
    end

    def redirect_locked_clients
      # TODO: make state file specific locked account page??
      redirect_to account_locked_portal_client_logins_path if @intakes.map(&:access_locked?).any?
    end
  end
end