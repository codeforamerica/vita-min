module Hub
  class CtcIntakeCapacityController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index
      @form = CtcIntakeCapacity.new
      @recent_intake_capacities = CtcIntakeCapacity.last(5).reverse
    end

    def create
      CtcIntakeCapacity.create(user: current_user, capacity: params[:ctc_intake_capacity][:capacity])
      redirect_to hub_ctc_intake_capacity_index_path
    end
  end
end