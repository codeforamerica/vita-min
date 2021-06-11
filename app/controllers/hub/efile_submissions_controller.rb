module Hub
  class EfileSubmissionsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource
    layout "admin"
  end
end