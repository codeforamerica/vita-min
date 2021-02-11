class PublicPagesController < ApplicationController
  skip_before_action :check_maintenance_mode
  def include_analytics?
    true
  end

  def redirect_locale_home
    redirect_to root_path, { locale: I18n.locale }
  end

  def source_routing
    source_parameter = SourceParameter.includes(:vita_partner).find_by(code: params[:source]&.downcase)
    if source_parameter.present?
      flash[:notice] = I18n.t("controllers.public_pages.partner_welcome_notice", partner_name: source_parameter.vita_partner.name)
      cookies[:intake_open] = { value: DateTime.current, expires: 1.year.from_now.utc }
    end
    redirect_to root_path, { locale: I18n.locale }
  end

  def home; end

  def other_options; end

  def maybe_ineligible; end

  def privacy_policy; end

  def about_us; end

  def maintenance; end

  def internal_server_error; end

  def page_not_found; end

  def tax_questions; end

  def stimulus_recommendation; end

  def sms_terms; end
end
