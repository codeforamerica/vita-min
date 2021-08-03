module AuthenticatedCtcClientConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_client_login
    after_action :update_session_time
  end

  private

  def update_session_time
    current_client.touch :last_seen_at
  end

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
