module Hub
  class BulkSignupMessagesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :set_main_heading, only: [:index, :create]
    load_and_authorize_resource :signup_selection, parent: false

    layout "hub"

    def index
      @signup_selection = SignupSelection.new
    end

    def create
      @signup_selection = SignupSelection.new(create_params)
      if @signup_selection.save
        redirect_to action: :index
      else
        render :index
      end
    end

    private

    def create_params
      params.require(:signup_selection).permit(:upload, :signup_type).merge(user: current_user)
    end

    def set_main_heading
      @main_heading = "Bulk messages to signups"
    end
  end
end
