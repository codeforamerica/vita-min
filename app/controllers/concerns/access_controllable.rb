module AccessControllable
  private

  def require_sign_in(redirect_after_login: nil )
    if current_user.present? && !current_user.admin? && current_user.should_enforce_strong_password && current_user.high_quality_password_as_of.nil?
      redirect_to Hub::Users::StrongPasswordsController.to_path_helper
    end

    if current_user.nil?
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

  def require_admin
    unless current_user.present? && current_user.admin?
      head :forbidden
    end
  end

  def require_engineer
    unless current_user.present? && current_user.admin? && current_user.role.engineer?
      redirect_to root_path
    end
  end

  def require_state_file
    unless current_user.present? && current_user.admin? && current_user.role.state_file?
      head :forbidden
    end
  end

  def prevent_greeter_access
    if current_user.present? && current_user.greeter?
      head :forbidden
    end
  end
end
