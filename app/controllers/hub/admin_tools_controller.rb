module Hub
  class AdminToolsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index; end
  end
end