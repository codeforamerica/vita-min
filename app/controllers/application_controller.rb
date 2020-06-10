class ApplicationController < ActionController::Base
  include ConsolidatedTraceHelper

  before_action :redirect_to_getyourrefund, :set_visitor_id, :set_source, :set_referrer, :set_utm_state, :set_sentry_context, :check_maintenance_mode, :check_at_capacity
  after_action :track_page_view
  around_action :switch_locale
  helper_method :include_google_analytics?, :current_intake

  # This needs to be a class method for the devise controller to have access to it
  # See: http://stackoverflow.com/questions/12550564/how-to-pass-locale-parameter-to-devise
  def self.default_url_options
    { locale: I18n.locale }.merge(super)
  end

  def current_intake
    Intake.find_by_id(session[:intake_id])
  end

  def current_diy_intake
    DiyIntake.find_by_id(session[:diy_intake_id])
  end

  def include_google_analytics?
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
      cookies.permanent[:visitor_id] =  { value: visitor_id, httponly: true }
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
    path_exclusions = []
    path_exclusions << current_intake.id if current_intake.present?
    path_exclusions << current_diy_intake.id if current_diy_intake.present?

    MixpanelService.send_event(
      event_id: visitor_id,
      event_name: event_name,
      data: data,
      subject: current_intake,
      request: request,
      source: self,
      path_exclusions: []
    )
  end

  def append_info_to_payload(payload)
    super
    payload[:request_details] = {
      current_user_id: current_user&.id,
      intake_id: current_intake&.id,
      diy_intake_id: current_diy_intake&.id,
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
    # Set the locale in order of priority
    # 1) Language picker: query param 'new_locale'
    # 2) Previously set locale: query param 'locale' (added by default_url_options once I18n.locale is set)
    # 3) Browser settings: accept-header is examined if no params are set
    # 4) Default Fallback: from I18n.default_locale (we set it to :en)
    # TODO: uncomment to include browser settings when we unlock spanish translation
    # locale = params[:new_locale] || params[:locale] || http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
    locale = params[:new_locale] || params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end


  private

  ##
  # when the session's current intake doesn't have a ticket, this will
  # redirect to the beginning of question navigation
  def require_ticket
    redirect_or_add_flash unless current_intake&.intake_ticket_id
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

  def check_at_capacity
    redirect_to at_capacity_path and return if ENV['AT_CAPACITY'].present?
  end
end
