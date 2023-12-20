module AuthenticatedStateFileIntakeConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_state_file_intake_login
  end

  private

  def card_postscript
    I18n.t("state_file.state_file_pages.card_postscript.responses_saved_html").html_safe
  end

  def require_state_file_intake_login
    if current_state_file_az_intake.blank? && current_state_file_ny_intake.blank?
      session[:after_state_file_intake_login_path] = request.original_fullpath if request.get?
      redirect_to root_path
    end
  end
end