class PublicPagesController < ApplicationController
  skip_before_action :check_maintenance_mode
  def include_analytics?
    true
  end

  def redirect_locale_home
    redirect_to root_path, { locale: I18n.locale }
  end

  def source_routing
    source_parameter = SourceParameter.find_by(code: params[:source])
    if source_parameter&.vita_partner_id
      session[:referring_organization_id] = source_parameter.vita_partner_id
    end
    redirect_locale_home
  end

  def home; end

  def diy_home; end

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
