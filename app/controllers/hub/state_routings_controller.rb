module Hub
  class StateRoutingsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "admin"

    def index
      @state_routings = VitaPartnerState.joins(:vita_partner).order(state: :asc).all.group_by(&:state).sort
    end
  end
end