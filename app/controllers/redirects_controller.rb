class RedirectsController < ApplicationController
  def outreach
    redirect_to(
      root_url(locale: params[:locale], utm_source: "gyr", utm_medium: "sms", utm_campaign: "w1"),
      allow_other_host: true
    )
  end
end
