module StateFile
  class IntakeLoginsController < Portal::ClientLoginsController
    helper_method :prev_path, :illustration_path
    before_action :redirect_to_data_review_if_intake_authenticated
    layout "state_file/question"

    # where they enter phone or email
    def new
      @contact_method = params[:contact_method]
      unless ["email_address", "sms_phone_number"].include?(@contact_method)
        return render "public_pages/page_not_found", status: 404
      end
      super
    end

    # create is the submit on the phone/email page

    def edit
      # TODO: the place where they enter SSN
      super
    end

    def update
      # TODO: the place where SSN is checked and they log in
      super
    end

    private

    def prev_path; end

    def illustration_path; end

    def after_create_invalid
      @contact_method = params[:contact_method]
      if @form.errors[:email_address].include?(I18n.t("forms.errors.need_one_communication_method"))
        @form.errors.add(:sms_phone_number, I18n.t("errors.messages.blank"))
        @form.errors.add(:email_address, I18n.t("errors.messages.blank"))
        @form.errors[:email_address].delete(I18n.t("forms.errors.need_one_communication_method"))
      end
      render :new, params: params
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