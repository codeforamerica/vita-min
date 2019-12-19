class LocationSearchesController < ApplicationController
  def new
    @locations = ScrapeVitaProvidersService.new().import
  end
end