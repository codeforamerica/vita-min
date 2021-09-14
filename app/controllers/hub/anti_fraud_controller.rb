module Hub
  class AntiFraudController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    layout "admin"

    def show
      @client = Client.find(params[:id])
    end
  end
end
