module ClientAccessControlConcern
  extend ActiveSupport::Concern

  private

  def require_client_login
    unless current_client.present?
      session[:after_client_login_path] = request.original_fullpath if request.get?
      redirect_to new_portal_client_login_path
    end
  end
end