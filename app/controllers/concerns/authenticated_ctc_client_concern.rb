module AuthenticatedCtcClientConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_client_login
  end

  private

  def current_intake
    current_client&.intake
  end

  def require_client_login
    if current_client.blank?
      session[:after_client_login_path] = request.original_fullpath if request.get?
      redirect_to new_ctc_portal_client_login_path
    end
  end
end