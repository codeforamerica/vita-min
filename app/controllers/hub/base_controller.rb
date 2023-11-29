module Hub
  class BaseController < ApplicationController
    include AccessControllable
    before_action :set_cache_headers, :require_sign_in

  end
end