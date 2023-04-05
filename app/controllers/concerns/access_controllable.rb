module AccessControllable
  private

  def require_sign_in(redirect_after_login: nil )
    if current_user.present?
      return if current_user.admin? || current_user.high_quality_password_as_of.present? || current_user.signed_in_after_strong_password_change.nil?
      return if controller_name == Hub::StrongPasswordsController.controller_name

      redirect_to Hub::StrongPasswordsController.to_path_helper
    else
      respond_to do |format|
        format.html do
          session[:after_login_path] = redirect_after_login || request.original_fullpath
          redirect_to new_user_session_path
        end
        format.js do
          head :forbidden
        end
      end
    end
  end

  def require_engineer
    unless current_user.present? && current_user.admin? && current_user.role.engineer?
      redirect_to root_path
    end
  end
end