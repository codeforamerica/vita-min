class ApplicationController < ActionController::Base
  include ConsolidatedTraceHelper
  around_action :set_time_zone, if: :current_user
  before_action :set_eitc_beta_cookie, :set_ctc_beta_cookie, :set_visitor_id, :set_source, :set_referrer, :set_utm_state, :set_navigator, :set_sentry_context, :set_collapse_main_menu, :set_get_started_link
  around_action :switch_locale
  before_action :check_maintenance_mode
  after_action :track_page_view
  helper_method :include_analytics?, :include_optimizely?, :current_intake, :current_tax_year, :prior_tax_year, :show_progress?, :show_offseason_banner?, :canonical_url, :hreflang_url, :hub?, :wrapping_layout
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

  def current_tax_year
    TaxReturn.current_tax_year.to_i
  end

  def prior_tax_year
    current_tax_year - 1
  end

  def intake_from_completed_session
    Intake.find_by_id(session[:completed_intake_id]) unless session[:completed_intake_id].nil?
  end

  def clear_intake_session
    sign_out current_client
    session.delete("intake_id")
  end

  def sign_in(*args)
    super
    session.delete("intake_id")
  end

  def include_analytics?
    false
  end

  def include_optimizely?
    # Adding Optimizely to a page increases risk; controller subclasses can opt-in to that.
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

  # Allow session[:source] to re-set on every interaction so we can track all
  # unique source entry points in Mixpanel.
  def set_source
    source_from_params = params[:source] || params[:utm_source] || params[:s]
    if source_from_params.present?
      # Use at most 100 chars in session so we don't overflow it.
      session[:source] = source_from_params.slice(0, 100)
    end
  end

  def set_ctc_beta_cookie
    return unless Routes::CtcDomain.new.matches?(request)
    ctc_beta = params[:ctc_beta]
    if ctc_beta == "1"
      cookies.permanent[:ctc_beta] = true
    end
  end

  def set_eitc_beta_cookie
    return unless Routes::CtcDomain.new.matches?(request)
    return unless app_time >= Rails.configuration.eitc_soft_launch

    eitc_beta = params[:eitc_beta]
    if eitc_beta == "1"
      cookies.permanent[:eitc_beta] = true
    end
  end

  def referrer
    session[:referrer]
  end

  def referrer_from_different_host?
    referrer_host = URI.parse(request.headers[:referer]).host rescue nil
    referrer_host != request.host
  end

  def set_referrer
    return unless referrer_from_different_host?

    # Use at most 200 chars in the session to avoid overflow.
    header_value = request.headers.fetch(:referer, "None")
    if header_value != "None" || session[:referrer].nil?
      session[:referrer] = header_value.slice(0, 200)
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

  def set_get_started_link
    I18n.with_locale(locale) do
      @get_started_link = open_for_gyr_intake? ? question_path(GyrQuestionNavigation.first) : nil
    end
  end

  def user_agent
    @user_agent ||= DeviceDetector.new(request.user_agent)
  end

  def track_page_view
    send_mixpanel_event(event_name: "page_view") if request.get?
  end

  def track_first_visit(page_name)
    event_name = "visit_#{page_name}"
    Analytics::Event.create_or_find_by!(client: current_intake.client, event_type: "first_#{event_name}")
    send_mixpanel_event(event_name: event_name)
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

  def set_collapse_main_menu
    @collapse_main_menu = cookies[:sidebar] == "collapsed"
  end

  def switch_locale(&action)
    I18n.with_locale(locale, &action)
  end

  def show_progress?
    false
  end

  # Do not show the offseason banner in the hub
  # Do not show offseason banner if we are open for intake for the session
  def show_offseason_banner?
    return false if hub?
    !open_for_gyr_intake?
  end

  def open_for_gyr_intake?
    return true if cookies[:used_unique_link] == "yes" &&
      app_time >= Rails.configuration.start_of_unique_links_only_intake &&
      app_time <= Rails.configuration.end_of_intake

    return app_time >= Rails.configuration.start_of_open_intake && app_time <= Rails.configuration.end_of_intake
  end
  helper_method :open_for_gyr_intake?

  def open_for_gyr_logged_in_clients?
    app_time >= Rails.configuration.start_of_unique_links_only_intake && app_time <= Rails.configuration.end_of_login
  end
  helper_method :open_for_gyr_logged_in_clients?

  def open_for_ctc_intake?
    return false if app_time >= Rails.configuration.ctc_end_of_intake

    return true if app_time >= Rails.configuration.ctc_full_launch
    app_time >= Rails.configuration.ctc_soft_launch && cookies[:ctc_beta].present?
  end
  helper_method :open_for_ctc_intake?

  def open_for_eitc_intake?
    return true if Flipper.enabled?(:eitc)

    app_time >= Rails.configuration.eitc_soft_launch && cookies[:eitc_beta].present?
  end
  helper_method :open_for_eitc_intake?

  def open_for_ctc_login?
    return false if app_time >= Rails.configuration.ctc_end_of_login

    return true if app_time >= Rails.configuration.ctc_full_launch
    app_time >= Rails.configuration.ctc_soft_launch && cookies[:ctc_beta].present?
  end
  helper_method :open_for_ctc_login?

  private

  def locale
    available_locale(params[:locale]) ||
      available_locale_from_domain ||
      http_accept_language.compatible_language_from(I18n.available_locales) ||
      I18n.default_locale
  end

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
    GyrQuestionNavigation
  end

  # convenience method for redirection to beginning of
  # intake process
  def redirect_to_beginning_of_intake
    redirect_to(question_path(id: question_navigator.first))
  end

  def redirect_to_intake_after_triage
    if Rails.env.production?
      redirect_to Questions::OverviewController.to_path_helper
    else
      redirect_to Questions::EnvironmentWarningController.to_path_helper
    end
  end

  def redirect_or_add_flash
    if Rails.env.production? || Rails.env.test?
      redirect_to_beginning_of_intake
    else
      flash[:alert] = I18n.t("controllers.application_controller.redirect")
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

  # Rails's CSRF countermeasures trigger two exceptions. Mostly these are triggered by security scans.
  # Catch them to avoid being noisy in logs etc.
  rescue_from 'ActionController::InvalidCrossOriginRequest' do
    DatadogApi.increment("rails.invalid_cross_origin_request")
    respond_to do |format|
      format.any { head 422 }
    end
  end

  rescue_from 'ActionController::InvalidAuthenticityToken' do
    DatadogApi.increment("rails.invalid_authenticity_token")
    flash[:alert] = I18n.t('general.authenticity_token_invalid')

    redirect_path = request.referer.presence || request.fullpath
    redirect_to redirect_path
  end

  rescue_from 'ActionController::UnknownFormat' do
    respond_to do |format|
      format.any { head 404 }
    end
  end

  rescue_from 'ActionController::Redirecting::UnsafeRedirectError' do
    respond_to do |format|
      format.any { head 400 }
    end
  end
end
