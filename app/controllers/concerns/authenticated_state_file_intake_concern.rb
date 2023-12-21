module AuthenticatedStateFileIntakeConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_state_file_intake_login
  end

  private

  def require_state_file_intake_login
    if current_state_file_az_intake.blank? && current_state_file_ny_intake.blank?
      session[:after_state_file_intake_login_path] = request.original_fullpath if request.get?
      redirect_to StateFile::StateFilePagesController.to_path_helper(action: :login_options, us_state: params[:us_state])
    end
  end
end