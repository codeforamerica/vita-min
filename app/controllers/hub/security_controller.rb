module Hub
  class SecurityController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource :client
    layout "admin"

    def show
      @client = Client.find(params[:id])
      @security_events = (
        @client.efile_security_informations + @client.recaptcha_scores
      ).sort_by(&:created_at)
    end
  end
end
