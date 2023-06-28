module Hub
  class AnalyticsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource parent: false
    load_and_authorize_resource :client
    load_and_authorize_resource through: :client, only: [:create]
    load_and_authorize_resource :user, parent: false, only: [:index]
    layout "hub"

    def index
    end
  end
end
