class UsersController < ApplicationController
  include AccessControllable

  before_action :require_sign_in
  before_action :require_beta_tester

  layout "admin"

  def profile
  end
end
