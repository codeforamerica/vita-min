class UsersController < ApplicationController
  include AccessControllable

  before_action :require_sign_in

  layout "admin"

  def profile
  end
end
