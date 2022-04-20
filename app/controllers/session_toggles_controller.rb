class SessionTogglesController < ApplicationController
  layout "hub"
  include AccessControllable
  before_action :require_sign_in, if: -> { Rails.env.production? }

  def index
    @toggle = SessionToggle.new(session, 'app_time')
  end

  def create
    @toggle = SessionToggle.new(session, 'app_time')
    if params[:clear]
      @toggle.clear
    else
      @toggle.value = params[:session_toggle][:value]
      @toggle.save
    end

    redirect_to action: :index
  end
end
