module StateFile
  class IntakeLoginsController < Portal::ClientLoginsController
    before_action :redirect_to_data_review_if_intake_authenticated

    def new
      unless ["email_address", "sms_phone_number"].include?(params[:contact_method])
        return render "public_pages/page_not_found", status: 404
      end
      super
    end

    private

    def after_create_valid
      # TODO: make new view for entering code
      super
    end

    def after_create_invalid
      # TODO: params don't go through
      # redirect_to action: :new, params: { us_state: params[:us_state], contact_method: params[:contact_method] }
      super
    end

    def validate_token; # TODO: actually do something here?
    end

    def redirect_locked_clients; # TODO: actually do something here?
    end

    def service_type
      :statefile
    end

    def redirect_to_data_review_if_intake_authenticated
      redirect_to StateFile::Questions::DataReviewController.to_path_helper(us_state: params[:us_state]) if current_state_file_az_intake.present? || current_state_file_ny_intake.present?
    end
  end
end