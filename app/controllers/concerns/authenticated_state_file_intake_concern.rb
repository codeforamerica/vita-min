module AuthenticatedStateFileIntakeConcern
  extend ActiveSupport::Concern
  include StateFile::StateFileControllerConcern

  included do
    before_action :require_state_file_intake_login
  end

  private

  def card_postscript
    I18n.t("state_file.state_file_pages.card_postscript.responses_saved_html").html_safe
  end

  def require_state_file_intake_login
    if current_intake.blank?
      session[:after_state_file_intake_login_path] = request.original_fullpath if request.get?
      redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: params[:us_state])
    end
  end
end