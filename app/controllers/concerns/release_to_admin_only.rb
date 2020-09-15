module ReleaseToAdminOnly
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication, :require_admin_user
  end

  def require_authentication
    unless current_user.present?
      session[:after_login_path] = request.path
      redirect_to zendesk_sign_in_path
    end
  end

  def require_admin_user
    head 403 unless current_user&.role == "admin"
  end
end