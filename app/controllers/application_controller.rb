class ApplicationController < ActionController::Base
  before_action :redirect_to_getyourrefund, :set_visitor_id, :set_source, :set_referrer, :set_utm_state, :set_sentry_context, :check_maintenance_mode
  after_action :track_page_view
  helper_method :include_google_analytics?

  def current_intake
    current_user&.intake || Intake.find_by_id(session[:intake_id])
  end

  def include_google_analytics?
    false
  end

  def set_visitor_id
    if current_intake&.visitor_id.present?
      cookies.permanent[:visitor_id] = current_intake.visitor_id
    elsif cookies[:visitor_id].present?
      visitor_id = cookies[:visitor_id]
    else
      visitor_id = SecureRandom.hex(26)
      cookies.permanent[:visitor_id] = visitor_id
    end
    if current_intake.present? && current_intake.persisted? && current_intake.visitor_id.blank?
      current_intake.update(visitor_id: visitor_id)
    end
  end

  def visitor_id
    current_intake&.visitor_id || cookies[:visitor_id]
  end

  def source
    session[:source]
  end

  def set_source
    source_from_params = params[:source] || params[:utm_source] || params[:s]
    if source_from_params.present?
      session[:source] = source_from_params
    elsif request.headers.fetch(:referer, "").include?("google.com")
      session[:source] = "organic_google"
    end
  end

  def referrer
    session[:referrer]
  end

  def set_referrer
    unless referrer.present?
      session[:referrer] = request.headers.fetch(:referer, "None")
    end
  end

  def utm_state
    session[:utm_state]
  end

  def set_utm_state
    return unless params[:utm_state].present?

    unless utm_state.present?
      session[:utm_state] = params[:utm_state]
    end
  end

  def user_agent
    @user_agent ||= DeviceDetector.new(request.user_agent)
  end

  def track_page_view
    send_mixpanel_event(event_name: "page_view") if request.get?
  end

  def send_mixpanel_validation_error(errors, additional_data = {})
    invalid_field_flags = errors.keys.map { |key| ["invalid_#{key}".to_sym, true] }.to_h
    tracking_data = invalid_field_flags.merge(additional_data)
    send_mixpanel_event(event_name: "validation_error", data: tracking_data)
  end

  def send_mixpanel_event(event_name:, data: {})
    return if user_agent.bot?
    major_browser_version = user_agent.full_version.try { |v| v.partition('.').first }
    default_data = {
      source: source,
      referrer: referrer,
      utm_state: utm_state,
      referrer_domain: URI.parse(referrer).host || "None",
      full_user_agent: request.user_agent,
      browser_name: user_agent.name,
      browser_full_version: user_agent.full_version,
      browser_major_version: major_browser_version,
      os_name: user_agent.os_name,
      os_full_version: user_agent.os_full_version,
      os_major_version: user_agent.os_full_version.try { |v| v.partition('.').first },
      is_bot: user_agent.bot?,
      bot_name: user_agent.bot_name,
      device_brand: user_agent.device_brand,
      device_name: user_agent.device_name,
      device_type: user_agent.device_type,
      device_browser_version: "#{user_agent.os_name} #{user_agent.device_type} #{user_agent.name} #{major_browser_version}",
      locale: I18n.locale.to_s,
      path: request.path,
      full_path: request.fullpath,
      controller_name: self.class.name.sub("Controller", ""),
      controller_action: "#{self.class.name}##{action_name}",
      controller_action_name: action_name,
      sign_in_count: current_user&.sign_in_count,
      current_sign_in_at: current_user&.current_sign_in_at,
      last_sign_in_at: current_user&.last_sign_in_at,
    }
    default_data.merge!(current_intake.mixpanel_data) if current_intake.present?
    MixpanelService.instance.run(
      unique_id: visitor_id,
      event_name: event_name,
      data: default_data.merge(data),
    )
  end

  def append_info_to_payload(payload)
    super
    payload[:request_details] = {
      user_id: current_user&.id,
      intake_id: current_intake&.id,
      device_type: user_agent.device_type,
      browser_name: user_agent.name,
      os_name: user_agent.os_name,
      request_id: request.request_id,
      visitor_id: visitor_id,
      referrer: referrer,
      ip: request.remote_ip
    }
  end

  def set_sentry_context
    Raven.user_context id: current_user&.id, intake_id: current_intake&.id
    Raven.extra_context visitor_id: visitor_id, is_bot: user_agent.bot?, request_id: request.request_id
  end

  private

  def require_sign_in
    unless user_signed_in?
      redirect_to identity_questions_path(after_login: request.path)
    end
  end

  def redirect_to_getyourrefund
    if request.get? && request.host.include?("vitataxhelp.org")
      return redirect_to request.original_url.gsub("vitataxhelp.org", "getyourrefund.org")
    end
  end

  def check_maintenance_mode
    if ENV['MAINTENANCE_MODE'].present?
      return redirect_to maintenance_path
    elsif ENV['MAINTENANCE_MODE_SCHEDULED'].present?
      flash.now[:warning] = "GetYourRefund.org will be down for scheduled maintenance tonight at 11:00 p.m. Eastern (8:00 p.m. Pacific) until 3:00 a.m. Eastern (12:00 a.m. Pacific). We recommend that you answer all questions by this time or start a new session tomorrow."
    end
  end
end
