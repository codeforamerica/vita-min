module Hub
  class IntakesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    authorize_resource
    load_resource except: [:index, :show]
    layout "hub"

    def index
      @intakes = StateFileAzIntake.accessible
    end

    def show
      @intake = StateFileAzIntake.find(params[:id])
    end

  end
end
