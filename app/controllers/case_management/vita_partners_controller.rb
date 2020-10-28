module CaseManagement
  class VitaPartnersController < ApplicationController

    include AccessControllable

    before_action :require_sign_in
    load_and_authorize_resource

    layout "admin"

    def show; end
    def edit; end
    def update; end
  end
end