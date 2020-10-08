module AccessControllable
  private

  def require_sign_in(redirect_after_login: nil )
    unless current_user.present?
      session[:after_login_path] = redirect_after_login || request.path
      redirect_to zendesk_sign_in_path
    end
  end
end