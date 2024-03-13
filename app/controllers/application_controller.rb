class ApplicationController < ActionController::Base
  include ConsolidatedTraceHelper
  around_action :set_time_zone, if: :current_user
  before_action :set_eitc_beta_cookie, :set_ctc_beta_cookie, :set_visitor_id, :set_source, :set_referrer, :set_utm_state, :set_navigator, :set_sentry_context, :set_collapse_main_menu, :set_get_started_link
  around_action :switch_locale
  before_action :check_maintenance_mode
  before_action :redirect_state_file_in_off_season
  after_action :track_page_view, :track_form_submission

  before_action do
    if defined?(Rack::MiniProfiler) && current_user&.admin?
      Rack::MiniProfiler.authorize_request
    end
  end

  helper_method :include_analytics?, :current_intake, :show_progress?, :canonical_url, :hreflang_url, :hub?, :state_file?, :wrapping_layout
  # This needs to be a class method for the devise controller to have access to it
  # See: http://stackoverflow.com/questions/12550564/how-to-pass-locale-parameter-to-devise
  def self.default_url_options
    { locale: I18n.locale }.merge(super)
  end

  def self.i18n_base_path
    "views.#{controller_path.tr('/', '.')}"
  end

  def self.navigation_actions
    [:edit]
  end

  def self.to_path_helper(options = {})
    action = options.delete(:action) || :edit
    full_url = options.delete(:full_url) || false
    Rails.application.routes.url_helpers.url_for({
      controller: controller_path,
      action: action,
      only_path: !full_url,
      # url_for sometimes uses the current path to determine the right URL in some situations,
      # explicitly sending an empty _recall disables that behavior
      _recall: {}
    }.merge(default_url_options).merge(options))
  end

  def self.all_localized_paths
    Rails.configuration.i18n.available_locales.map { |locale| to_path_helper(locale: locale) }
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

  def state_file?
    self.class.name.include?("StateFile::") || request.domain&.include?("statefile") || request.domain&.include?("fileyourstatetaxes")
  end

  def hide_state_file_intercom?
    pages_to_hide_from = [
      "StateFile::StateFilePagesController", #about_page, privacy_policy
      "StateFile::FaqController"
    ]
    state_file? && pages_to_hide_from.include?(self.class.name)
    # paths_to_hide = [
    #   "/",
    #   "/privacy-policy",
    #   "/faq"
    # ]
    # state_file? && !paths_to_hide.any? { |path| request.path.include?(path)}
  end
  helper_method :hide_state_file_intercom?

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

  def sign_in(*args)
    super
    send_mixpanel_event(event_name: "hub_user_login")
    session.delete("intake_id")
  end

  def include_analytics?
    false
  end

  def visitor_record
    current_intake
  end

  def ip_for_irs
    if Rails.env.development?
      "72.34.67.178"
    else
      request.remote_ip
    end
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
    visitor_id =
      if visitor_record&.visitor_id.present?
        visitor_record.visitor_id
      elsif legacy_visitor_id_cookie.present?
        legacy_visitor_id_cookie
      elsif cookies.encrypted[:visitor_id].present?
        cookies.encrypted[:visitor_id]
      else
        SecureRandom.hex(26)
      end
    cookies.encrypted.permanent[:visitor_id] = { value: visitor_id, httponly: true }

    # If we run into cases where the intake does not have an associated visitor_id persisted onto it,
    # let's make sure it gets updated onto the record.
    if visitor_record.present? && visitor_record.persisted? && visitor_record.visitor_id.blank?
      visitor_record.update(visitor_id: visitor_id)
    end
  end

  def visitor_id
    visitor_record&.visitor_id || cookies.encrypted[:visitor_id]
  end

  def legacy_visitor_id_cookie
    val = cookies[:visitor_id]
    if !val.nil? && val.force_encoding("UTF-8").valid_encoding? && val.present? && val.length <= 52
      val
    end
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
      @get_started_link = open_for_gyr_intake? ? question_path(Questions::TriagePersonalInfoController) : nil
    end
  end

  def user_agent
    @user_agent ||= DeviceDetector.new(request.user_agent)
  end

  def track_page_view
    send_mixpanel_event(event_name: "page_view") if request.get?
  end

  def track_form_submission
    send_mixpanel_event(event_name: "form_submission") if %w[POST PUT PATCH DELETE].include?(request.request_method) && (200..399).include?(response.status)
  end

  def track_first_visit(page_name)
    event_name = "visit_#{page_name}"
    send_mixpanel_event(event_name: event_name)
    db_event_name = "first_#{event_name}"
    Analytics::Event.find_or_create_by(client: current_intake.client, event_type: db_event_name)
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
      user: current_user,
      request: request,
      source: self,
      path_exclusions: all_identifiers
    )
  end

  def append_info_to_payload(payload)
    super
    payload[:level] =
      case payload[:status]
      when (400..499)
        "WARN"
      when (500..599)
        "ERROR"
      else
        "INFO"
      end

    current_user_id = current_user&.id rescue nil

    payload[:request_details] = {
      current_user_id: current_user_id,
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

  def homepage_banner
    if app_time <= Rails.configuration.tax_deadline && open_for_gyr_intake?
      # after open intake, before tax_deadline
      :open_intake
    elsif app_time.between?(Rails.configuration.tax_deadline, Rails.configuration.end_of_in_progress_intake)
      # after tax_deadline, before end_of_in_progress_intake
      :in_progress_intake_only
    elsif app_time.between?(Rails.configuration.end_of_in_progress_intake, Rails.configuration.end_of_login)
      # after end_of_in_progress_intake, before end_of_login
      :login_only
    elsif Rails.configuration.end_of_login <= app_time
      # after end of login
      :off_season
    end
  end
  helper_method :homepage_banner

  def open_for_gyr_intake?
    # has unique link && start_of_unique_links_only_intake < time < end_of_intake
    return true if cookies[:used_unique_link] == "yes" &&
      app_time >= Rails.configuration.start_of_unique_links_only_intake &&
      app_time <= Rails.configuration.end_of_intake

    # start_of_open_intake < time < end_of_intake
    return app_time >= Rails.configuration.start_of_open_intake && app_time <= Rails.configuration.end_of_intake
  end
  helper_method :open_for_gyr_intake?

  def open_for_finishing_in_progress_intakes?
    app_time >= Rails.configuration.end_of_intake && app_time <= Rails.configuration.end_of_in_progress_intake
  end
  helper_method :open_for_finishing_in_progress_intakes?

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
    return true if app_time >= Rails.configuration.eitc_full_launch

    app_time >= Rails.configuration.eitc_soft_launch && cookies[:eitc_beta].present?
  end
  helper_method :open_for_eitc_intake?

  def open_for_ctc_login?
    return false if app_time >= Rails.configuration.ctc_end_of_login

    return true if app_time >= Rails.configuration.ctc_full_launch
    app_time >= Rails.configuration.ctc_soft_launch && cookies[:ctc_beta].present?
  end
  helper_method :open_for_ctc_login?

  def open_for_ctc_read_write?
    app_time <= Rails.configuration.ctc_end_of_read_write
  end
  helper_method :open_for_ctc_read_write?

  def open_for_state_file_intake?
    app_time.between?(Rails.configuration.state_file_start_of_open_intake, Rails.configuration.state_file_end_of_intake)
  end
  helper_method :open_for_state_file_intake?

  def before_state_file_launch?
    app_time <= Rails.configuration.state_file_start_of_open_intake
  end
  helper_method :before_state_file_launch?

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
  helper_method :app_time

  def acts_like_production?
    Rails.env.production?
  end
  helper_method :acts_like_production?

  def show_xml?
    Rails.env.development? || Rails.env.heroku? || Rails.env.test?
  end
  helper_method :show_xml?

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
    Navigation::GyrQuestionNavigation
  end

  # convenience method for redirection to beginning of
  # intake process
  def redirect_to_beginning_of_intake
    redirect_to(question_path(id: question_navigator.first))
  end

  def redirect_to_intake_after_triage
    if Rails.env.production?
      redirect_to Questions::PersonalInfoController.to_path_helper
    else
      redirect_to Questions::EnvironmentWarningController.to_path_helper
    end
  end

  def redirect_state_file_in_off_season
    return unless state_file?
    protected_page = hub? ||
      self.class.name.include?("SessionTogglesController") ||
      (self.class.name.include?("StateFilePagesController") && action_name == "coming_soon") ||
      self.class.name.include?("StateFile::FaqController")
    return if protected_page

    if before_state_file_launch?
      redirect_to StateFile::StateFilePagesController.to_path_helper(action: :coming_soon)
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
    @users = User.active.accessible_by(current_ability).order(name: :asc)
  end

  def set_current_step
    return unless current_intake&.persisted?
    return unless request.get? # skip uploads

    current_intake.update!(current_step: current_path) unless current_intake.current_step == current_path
  end

  def wrapping_layout
    "application"
  end

  def set_no_cache_headers
    # prevents browser caching on pages set with before action
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Mon, 01 Jan 1990 00:00:00 GMT"
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

  rescue_from 'ArgumentError' do |error|
    respond_to do |format|
      format.any do
        if error.message == "string contains null byte"
          head 400
        else
          raise
        end
      end
    end
  end
end
