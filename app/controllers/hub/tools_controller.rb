module Hub
  class ToolsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    layout "hub"

    def index; end
  end
end