class ApplicationController < ActionController::Base
  CTC_INTAKE_CLOSING_TIME = Time.find_zone('America/Los_Angeles').parse('2021-11-15 23:59:59')
  CTC_LOGIN_CLOSING_TIME = Time.find_zone('America/Los_Angeles').parse('2021-11-19 23:59:59')

  include ConsolidatedTraceHelper
  around_action :set_time_zone, if: :current_user
  before_action :redirect_to_getyourrefund, :set_visitor_id, :set_source, :set_referrer, :set_utm_state, :set_navigator, :set_sentry_context, :set_initial_main_menu_state
  around_action :switch_locale
  before_action :check_maintenance_mode
  after_action :track_page_view
  helper_method :include_analytics?, :current_intake, :show_progress?, :show_offseason_banner?, :canonical_url, :hreflang_url, :hub?, :open_for_intake?, :open_for_ctc_intake?, :open_for_ctc_login?, :wrapping_layout
  # This needs to be a class method for the devise controller to have access to it
  # See: http://stackoverflow.com/questions/12550564/how-to-pass-locale-parameter-to-devise
  def self.default_url_options
    { locale: I18n.locale }.merge(super)
  end

  def self.i18n_base_path
    "views.#{controller_path.tr('/', '.')}"
  end

  def self.to_path_helper(options = {})
    action = options.delete(:action) || :edit
    Rails.application.routes.url_helpers.url_for({
      controller: controller_path,
      action: action,
      only_path: true,
      # url_for sometimes uses the current path to determine the right URL in some situations,
      # explicitly sending an empty _recall disables that behavior
      _recall: {}
    }.merge(default_url_options).merge(options))
  end

  def canonical_url(locale=I18n.locale)
    # Leave the locale out of canonical URLs in the default locale (works ok either way but needs to be consistent)
    url_for(only_path: false, locale: locale)
  end

  # It would be preferable to always get this from the controller namespace in all cases,
  # but the devise controllers are not under the hub namespace so I'm leaving the request.path.include? string as well.
  def hub?
    self.class.name.include?("Hub::") || request.path.include?("hub")
  end

  def current_intake
    current_client&.intake || (Intake.find_by_id(session[:intake_id]) unless session[:intake_id].nil?)
  end

  def intake_from_completed_session
    Intake.find_by_id(session[:completed_intake_id]) unless session[:completed_intake_id].nil?
  end

  def clear_intake_session
    sign_out current_client
    session.delete("intake_id")
  end

  def include_analytics?
    false
  end

  def visitor_record
    current_intake
  end

  def self.model_for_show_check(current_controller)
    current_controller.visitor_record
  end

  def self.deprecated_controller?
    false
  end

  def current_resource
    nil
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
    # If we run into cases where the intake does not have an associated visitor_id persisted onto it,
    # let's make sure it gets updated onto the record.
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
    if !session[:source] && source_from_params.present?
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

  def set_navigator
    return unless params[:navigator].present?

    unless navigator.present?
      # Avoid using too much cookie space
      session[:navigator] = params[:navigator].slice(0, 1)
    end
  end

  def navigator
    session[:navigator]
  end

  def user_agent
    @user_agent ||= DeviceDetector.new(request.user_agent)
  end

  def track_page_view
    send_mixpanel_event(event_name: "page_view") if request.get?
  end

  def send_mixpanel_validation_error(errors, additional_data = {})
    invalid_field_flags = errors.attribute_names.map { |key| ["invalid_#{key}".to_sym, true] }.to_h

    MixpanelService.send_event(
      distinct_id: visitor_id,
      event_name: 'validation_error',
      data: invalid_field_flags.merge(additional_data),
      subject: current_intake,
      request: request,
      source: self
    )
  end

  def send_mixpanel_event(event_name:, data: {}, subject: nil)
    return if user_agent.bot?

    MixpanelService.send_event(
      distinct_id: visitor_id,
      event_name: event_name,
      data: data,
      subject: subject || visitor_record,
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
    Sentry.configure_scope do |scope|
      scope.set_user(id: current_intake&.id)
      scope.set_extras(
        intake_id: current_intake&.id,
        visitor_id: visitor_id,
        is_bot: user_agent.bot?,
        request_id: request.request_id,
        user_id: current_user&.id,
        client_id: current_client&.id
      )
    end
  end

  def set_initial_main_menu_state
    @initial_main_menu_state = cookies[:sidebar] == "collapsed" ? "collapsed" : "expanded"
  end

  def switch_locale(&action)
    locale = available_locale(params[:locale]) ||
      available_locale_from_domain ||
      http_accept_language.compatible_language_from(I18n.available_locales) ||
      I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def show_progress?
    false
  end

  # Do not show the offseason banner in the hub
  # Do not show offseason banner if we are open for intake for the session
  def show_offseason_banner?
    return false if hub?
    !open_for_intake?
  end

  def open_for_intake?
    !Rails.configuration.offseason
  end

  def open_for_ctc_intake?
    app_time <= CTC_INTAKE_CLOSING_TIME
  end

  def open_for_ctc_login?
    app_time <= CTC_LOGIN_CLOSING_TIME
  end

  private

  def app_time
    if Rails.env.production?
      Time.current
    else
      SessionToggle.new(session, 'app_time').value || Time.current
    end
  end

  def available_locale(locale)
    locale if I18n.available_locales.map(&:to_sym).include?(locale&.to_sym)
  end

  def available_locale_from_domain
    available_locale('es') if request.domain == 'mireembolso.org'
  end

  def require_intake
    redirect_to_beginning_of_intake unless current_intake.present?
  end

  def question_navigator
    QuestionNavigation
  end

  # convenience method for redirection to beginning of
  # intake process
  def redirect_to_beginning_of_intake
    redirect_to(question_path(id: question_navigator.first))
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
      return render 'public_pages/maintenance', status: 503, layout: 'application'
    elsif ENV['MAINTENANCE_MODE_SCHEDULED'].present?
      flash.now[:warning] = I18n.t("controllers.application_controller.maintenance", time: ENV['MAINTENANCE_MODE_SCHEDULED'])
    end
  end

  ##
  # @return [Array(Object)] all potential identifiers
  def all_identifiers
    [
      params[:token],
      params[:intake_id],
      session[:intake_id],
      params[:id],
      params[:ticket_id],
    ].filter { |e| e && !e.to_s.empty? }.uniq
  end

  def after_sign_in_path_for(_user)
    @after_login_path || hub_assigned_clients_path
  end

  def set_time_zone
    Time.use_zone(current_user.timezone) { yield }
  end

  def load_vita_partners
    @vita_partners = VitaPartner.accessible_by(current_ability)
  end

  def load_users
    @users = User.accessible_by(current_ability).order(name: :asc)
  end

  def set_current_step
    return unless current_intake&.persisted?
    return unless request.get? # skip uploads

    current_intake.update!(current_step: current_path) unless current_intake.current_step == current_path
  end

  def wrapping_layout
    "application"
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        render status: :forbidden, template: "public_pages/forbidden", layout: "hub"
      end
      format.js { head :forbidden }
    end
  end
end
