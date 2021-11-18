class PublicPagesController < ApplicationController
  skip_before_action :check_maintenance_mode
  before_action :redirect_to_main_url_on_heroku, only: [:home]

  def include_analytics?
    true
  end

  def redirect_locale_home
    redirect_to root_path
  end

  def source_routing
    vita_partner = SourceParameter.find_vita_partner_by_code(params[:source])
    if vita_partner.present?
      flash[:notice] = I18n.t("controllers.public_pages.partner_welcome_notice", partner_name: vita_partner.name)
      cookies[:intake_open] = { value: DateTime.current, expires: 1.year.from_now.utc }
    end
    redirect_to root_path
  end

  def home; end

  def healthcheck
    render :home
  end

  def other_options; end

  def maybe_ineligible; end

  def privacy_policy; end

  def about_us; end

  def maintenance; end

  def internal_server_error
    respond_to do |format|
      format.html { render 'public_pages/internal_server_error', status: 500  }
      format.any { head 500 }
    end
  end

  def page_not_found
    respond_to do |format|
      format.html { render 'public_pages/page_not_found', status: 404  }
      format.any { head 404 }
    end
  end

  def tax_questions; end

  def stimulus_recommendation; end

  def sms_terms; end

  def diy
    redirect_to root_path if Rails.configuration.offseason
  end

  def pki_validation
    # Used for Identrust annual EV certificate validation
    respond_to do |format|
      format.text { render 'public_pages/pki_validation'  }
      format.any { head 404 }
    end
  end

  private

  def redirect_to_main_url_on_heroku
    return unless Rails.env.heroku?

    # On Heroku Review Apps, it's convenient to use our *.getyourrefund-testing.org URL where possible.
    if request.host != MultiTenantService.new(:gyr).host
      redirect_to(request.path, host: MultiTenantService.new(:gyr).host)
    end
  end
end
