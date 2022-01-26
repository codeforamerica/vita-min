module Hub
  class VerificationAttemptsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index
      @page_title = "Clients to be verified"
    end

    def show
      @client = Client.find(params[:id])
    end

  end
end
