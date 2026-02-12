class RedirectsController < ApplicationController
  def outreach
    redirect_to(
      "https://www.getyourrefund.org/?utm_source=gyr&utm_medium=sms&utm_campaign=w1",
      allow_other_host: true
    )
  end
end
