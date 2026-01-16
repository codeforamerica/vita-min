class VitaProvidersController < ApplicationController
  IRS_VITA_SITE_LOCATOR_URL = 'https://freetaxassistance.for.irs.gov/s/sitelocator'

  def include_analytics?
    true
  end

  def index
    redirect_to IRS_VITA_SITE_LOCATOR_URL, allow_other_host: true
  end
end
