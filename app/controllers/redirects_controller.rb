class RedirectsController < ApplicationController
  def outreach
    # for SMS only b/c utm_medium is defined as 'sms'
    redirect_to(
      root_url(locale: params[:locale].presence || I18n.default_locale, utm_source: "gyr", utm_medium: "sms", utm_campaign: "w1"),
      allow_other_host: true
    )
  end
end
