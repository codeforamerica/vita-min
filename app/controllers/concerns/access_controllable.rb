module AccessControllable
  private

  def require_sign_in(redirect_after_login: nil )
    unless current_user.present?
      session[:after_login_path] = redirect_after_login || request.path
      redirect_to new_user_session_path
    end
  end
end