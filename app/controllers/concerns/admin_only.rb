module AdminOnly
  extend ActiveSupport::Concern

  included do
    before_action :require_login
    before_action :require_admin_user
  end

  def require_login
    unless current_user.present?
      session[:after_login_path] = request.path
      redirect_to zendesk_sign_in_path
    end
  end

  def require_admin_user
    return head 403 unless current_user&.role == "admin"
  end
end