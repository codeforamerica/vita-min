module StateFile
  class IntakeLoginsController < Portal::ClientLoginsController
    helper_method :prev_path, :illustration_path
    layout "state_file/question"

    def new
      @contact_method = params[:contact_method]
      unless ["email_address", "sms_phone_number"].include?(@contact_method)
        return render "public_pages/page_not_found", status: 404
      end
      super
    end

    def create
      @contact_method = params[:contact_method] unless @contact_method.present?
      @form = request_login_form_class.new(request_client_login_params)
      if @form.valid?
        intake_classes = client_login_service.intake_classes
        @records = intake_classes.map { |intake_class| @form.filter_records(intake_class) }.flatten
        if @records.blank?
          flash[:alert] = I18n.t("state_file.intake_logins.new.#{@contact_method}.not_found")
          render :new and return
        end
      end
      super
    end

    def edit
      # Displays verify SSN form
      @form = IntakeLoginForm.new(possible_intakes: @records)
      if @records.all? { |intake| intake.hashed_ssn.nil? }
        sign_in_and_redirect
      end
    end

    def update
      # Validates SSN
      @form = IntakeLoginForm.new(intake_login_params)
      if @form.valid?
        sign_in_and_redirect
      else
        @records.each(&:increment_failed_attempts)

        # Re-checking if account is locked after incrementing
        return if redirect_locked_clients

        render :edit
      end
    end

    def account_locked; end

    private

    def redirect_locked_clients
      redirect_to account_locked_intake_logins_path if @records.map(&:access_locked?).any?
    end

    def prev_path; end

    def illustration_path; end

    def extra_path_params
      {
        us_state: params[:us_state]
      }
    end

    def intake_login_params
      params.require(:state_file_intake_login_form).permit(:ssn).merge(possible_intakes: @records)
    end

    def increment_failed_attempts_on_login_records
      contact_info = params[:portal_verification_code_form][:contact_info]
      intake_classes = client_login_service.intake_classes
      intake_classes.each do |intake_class|
        @records = intake_class.where(email_address: contact_info).or(intake_class.where(phone_number: contact_info))
        @records.map(&:increment_failed_attempts)
      end
    end

    def request_login_form_class
      RequestIntakeLoginForm
    end

    def request_client_login_params
      params.require(:state_file_request_intake_login_form).permit(:email_address, :sms_phone_number)
    end

    def service_type
      case params[:us_state]
      when "az" then :statefile_az
      when "ny" then :statefile_ny
      when "us" then :statefile
      end
    end

    def sign_in_and_redirect
      intake = @form.intake_to_log_in(@records)

      # Note: for god knows what reason, you cannot reference "current_state_file_#{state_code}_intake" or the new intake will fail to log in,
      # or at least in the test it seems to fail. Couldn't think of a better solution than grabbing the id from the session even though it looks terrible.
      # (Should return an array of 1 id)
      unfinished_logged_in_intake_id = session.dig("warden.user.state_file_#{params[:us_state]}_intake.key", 0)

      sign_in intake

      if unfinished_logged_in_intake_id.present? && unfinished_logged_in_intake_id[0] != intake.id
        intake.update(unfinished_intake_ids: intake.unfinished_intake_ids + unfinished_logged_in_intake_id)
      end

      to_path = session.delete(:after_state_file_intake_login_path)
      unless to_path
        controller = intake.controller_for_current_step
        # This can be removed once we are sure nobody has current_step set to landing_page
        navigation = "Navigation::StateFile#{intake.state_code.titleize}QuestionNavigation".constantize
        if navigation::FLOW.index(controller) < navigation::FLOW.index(StateFile::Questions::TermsAndConditionsController)
          controller = StateFile::Questions::TermsAndConditionsController
        end
        to_path = controller.to_path_helper(
          action: controller.navigation_actions.first,
          us_state: intake.state_code
        )
      end
      redirect_to to_path
    end
  end
end