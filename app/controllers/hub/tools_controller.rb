module Hub
  class ToolsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "admin"

    def index; end
  end
end