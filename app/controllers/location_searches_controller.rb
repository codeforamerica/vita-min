class LocationSearchesController < ApplicationController
  layout "client_facing"

  def new
    @locations = ScrapeVitaProvidersService.new().import
  end
end