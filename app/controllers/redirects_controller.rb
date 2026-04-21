class RedirectsController < ApplicationController
  # we use this controller to provide short links for our messages
  # to not spook clients with param clogged urls

  def outreach
    # for SMS only b/c utm_medium is defined as 'sms'
    redirect_to(
      root_url(locale: params[:locale].presence || I18n.default_locale, utm_source: "gyr", utm_medium: "sms", utm_campaign: "w1"),
      allow_other_host: true
    )
  end

  def gyr_outreach
    redirect_to(
      root_url(
        locale: params[:locale].presence || I18n.default_locale,
        utm_source: "gyr",
        utm_medium: params[:medium] || "sms",
        utm_campaign: "w2"),
      allow_other_host: true
    )
  end

  def fyst_outreach
    redirect_to(
      root_url(locale: params[:locale].presence || I18n.default_locale,
               utm_source: "gyr",
               utm_medium: params[:medium] || "sms",
               utm_campaign: "w2fyst"),
      allow_other_host: true
    )
  end

  def diy_survey
    redirect_to(
      "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_a48BAqQ7hknW2YC",
      allow_other_host: true
    )
  end
end
