module Hub
  class IntakesController < ApplicationController
    include AccessControllable

    before_action :require_sign_in
    authorize_resource
    load_resource except: [:index, :show]
    layout "hub"

    def index
      @intakes = Intake.all
    end

    def show
    end

  end
end
