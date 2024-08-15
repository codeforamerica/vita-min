module StateFile
  module StateFileIntakeConcern
    extend ActiveSupport::Concern
    include StateFile::StateFileControllerConcern

    included do
      before_action :require_state_file_intake_login
      helper_method :current_intake, :current_state_code, :current_state_name, :card_postscript
    end

    def current_intake
      StateFile::StateInformationService.active_state_codes
                                        .lazy
                                        .map { |c| send("current_state_file_#{c}_intake".to_sym) }
                                        .find(&:itself)
    end

    def current_state_code
      current_intake.state_code
    end

    def current_state_name
      StateFile::StateInformationService.state_name(current_state_code)
    end

    private

    def card_postscript
      I18n.t("state_file.state_file_pages.card_postscript.responses_saved_html").html_safe
    end

    def require_state_file_intake_login
      if current_intake.blank?
        session[:after_state_file_intake_login_path] = request.original_fullpath if request.get?
        flash[:notice] = I18n.t("devise.failure.timeout")
        redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options)
      end
    end
  end
end