class ZendeskController < ApplicationController
  skip_before_action :check_at_capacity

  layout "admin"

  def sign_in
  end
end
