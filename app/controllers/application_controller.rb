class ApplicationController < ActionController::Base
  include ConsolidatedTraceHelper

  before_action :redirect_to_getyourrefund, :set_visitor_id, :set_source, :set_referrer, :set_utm_state, :set_sentry_context, :check_maintenance_mode
  around_action :switch_locale
  after_action :track_page_view
  helper_method :include_analytics?, :current_intake, :show_progress?

  # This needs to be a class method for the devise controller to have access to it
  # See: http://stackoverflow.com/questions/12550564/how-to-pass-locale-parameter-to-devise
  def self.default_url_options
    { locale: I18n.locale }.merge(super)
  end

  def current_intake
    Intake.find_by_id(session[:intake_id])
  end

  def intake_from_completed_session
    Intake.find_by_id(session[:completed_intake_id])
  end

  def current_diy_intake
    DiyIntake.find_by_id(session[:diy_intake_id])
  end

  def current_stimulus_triage
    StimulusTriage.find_by_id(session[:stimulus_triage_id])
  end

  def clear_intake_session
    session.delete("intake_id")
  end

  def include_analytics?
    false
  end

  def visitor_record
    current_intake
  end

  def set_visitor_id
    if visitor_record&.visitor_id.present?
      cookies.permanent[:visitor_id] = { value: visitor_record.visitor_id, httponly: true }
    elsif cookies[:visitor_id].present?
      visitor_id = cookies[:visitor_id]
    else
      visitor_id = SecureRandom.hex(26)
      cookies.permanent[:visitor_id] = { value: visitor_id, httponly: true }
    end
    if visitor_record.present? && visitor_record.persisted? && visitor_record.visitor_id.blank?
      visitor_record.update(visitor_id: visitor_id)
    end
  end

  def visitor_id
    visitor_record&.visitor_id || cookies[:visitor_id]
  end

  def source
    session[:source]
  end

  def set_source
    source_from_params = params[:source] || params[:utm_source] || params[:s]
    if source_from_params.present?
      # Use at most 100 chars in session so we don't overflow it.
      session[:source] = source_from_params.slice(0, 100)
    elsif request.headers.fetch(:referer, "").include?("google.com")
      session[:source] = "organic_google"
    end
  end

  def referrer
    session[:referrer]
  end

  def set_referrer
    unless referrer.present?
      # Use at most 200 chars in the session to avoid overflow.
      session[:referrer] = request.headers.fetch(:referer, "None").slice(0, 200)
    end
  end

  def utm_state
    session[:utm_state]
  end

  def set_utm_state
    return unless params[:utm_state].present?

    unless utm_state.present?
      # Avoid using too much cookie space
      session[:utm_state] = params[:utm_state].slice(0, 50)
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

    MixpanelService.send_event(
      event_id: visitor_id,
      event_name: 'validation_error',
      data: invalid_field_flags.merge(additional_data),
      subject: current_intake,
      request: request,
      source: self
    )
  end

  def send_mixpanel_event(event_name:, data: {})
    return if user_agent.bot?

    MixpanelService.send_event(
      event_id: visitor_id,
      event_name: event_name,
      data: data,
      subject: visitor_record,
      request: request,
      source: self,
      path_exclusions: all_identifiers
    )
  end

  def append_info_to_payload(payload)
    super
    payload[:request_details] = {
      current_user_id: current_user&.id,
      intake_id: current_intake&.id,
      diy_intake_id: current_diy_intake&.id,
      stimulus_triage_id: current_stimulus_triage&.id,
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
    Raven.user_context intake_id: current_intake&.id
    Raven.extra_context visitor_id: visitor_id, is_bot: user_agent.bot?, request_id: request.request_id
  end

  def switch_locale(&action)
    locale = available_locale(params[:new_locale]) ||
      available_locale(params[:locale]) ||
      available_locale_from_domain ||
      http_accept_language.compatible_language_from(I18n.available_locales) ||
      I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def show_progress?
    false
  end

  private

  def available_locale(locale)
    locale if I18n.available_locales.map(&:to_sym).include?(locale&.to_sym)
  end

  def available_locale_from_domain
    available_locale('es') if request.domain == 'mireembolso.org'
  end

  ##
  # when the session's current intake doesn't have a ticket, this will
  # redirect to the beginning of question navigation
  def require_ticket
    # A reload is needed because separate code updates has_enqueued_ticket_creation.
    unless current_intake&.intake_ticket_id || current_intake&.reload&.has_enqueued_ticket_creation
      redirect_or_add_flash
    end
  end

  def require_intake
    redirect_to_beginning_of_intake unless current_intake.present?
  end

  ##
  # convenience method for redirection to beginning of
  # intake process
  def redirect_to_beginning_of_intake
    redirect_to(question_path(:id => QuestionNavigation.first))
  end

  def redirect_or_add_flash
    if Rails.env.production? || Rails.env.test?
      redirect_to_beginning_of_intake
    else
      flash[:alert] = I18n.t("controllers.application_controller.redirect")
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
      flash.now[:warning] = I18n.t("controllers.application_controller.maintenance")
    end
  end

  ##
  # @return [Array(Object)] all potential identifiers
  def all_identifiers
    [
      params[:token],
      params[:intake_id],
      session[:intake_id],
      params[:diy_intake_id],
      session[:diy_intake_id],
      params[:id],
      params[:ticket_id],
      current_intake&.intake_ticket_id,
      current_diy_intake&.ticket_id,
      (defined?(zendesk_ticket_id) && zendesk_ticket_id),
    ].filter { |e| e && !e.to_s.empty? }.uniq
  end

  def after_sign_in_path_for(_user)
    user_profile_path
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { head :forbidden }
    end
  end
end
