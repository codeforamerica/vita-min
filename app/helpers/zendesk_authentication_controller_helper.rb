module ZendeskAuthenticationControllerHelper
  def current_ticket
    return unless zendesk_ticket_id.present?

    @ticket ||= zendesk_client.tickets.find(id: zendesk_ticket_id)
  end

  def zendesk_client
    @zendesk_client ||= ZendeskAPI::Client.new do |config|
      config.access_token = current_user.access_token
      config.url = "https://eitc.zendesk.com/api/v2"
    end
  end

  def require_zendesk_user
    unless current_user&.provider == "zendesk"
      session[:after_login_path] = request.path
      redirect_to zendesk_sign_in_path
    end
  end

  def require_zendesk_admin
    return if require_zendesk_user
    unless current_user&.role == "admin"
      flash[:alert] = I18n.t("general.zendesk.access_denied")
      redirect_to zendesk_sign_in_path
    end
  end

  def require_ticket_access
    render "public_pages/page_not_found", status: 404 unless current_ticket.present?
  end
end
