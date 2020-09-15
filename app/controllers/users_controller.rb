class UsersController < ApplicationController
  include ReleaseToAdminOnly

  layout "admin"

  def profile
  end
end