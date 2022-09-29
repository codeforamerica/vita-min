module AuthenticatedCtcClientConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_client_login
    after_action :update_session_time
  end

  def track_click_history(event_name)
    history = DataScience::ClickHistory.create_or_find_by!(client: current_intake.client)
    history.update(event_name => DateTime.now) if history.send(event_name).nil?
    send_mixpanel_event(event_name: event_name.to_s)
  end

  private

  def update_session_time
    current_client&.touch :last_seen_at
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
