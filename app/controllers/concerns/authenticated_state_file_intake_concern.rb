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
    # NOTE: Most places in the code do not seem to use the authenticated version of
    # current_state_file_XX_intake - they use current_intake instead which is
    # unauthenticated.
    if current_state_file_az_intake.blank? && current_state_file_ny_intake.blank?
      session[:after_state_file_intake_login_path] = request.original_fullpath if request.get?
      redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: params[:us_state])
    end
  end
end