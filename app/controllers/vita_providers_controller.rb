class VitaProvidersController < ApplicationController
  layout "client_facing"

  def index
    @vita_providers = VitaProvider.all
  end
end