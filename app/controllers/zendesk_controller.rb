class ZendeskController < ApplicationController
  skip_before_action :check_at_capacity

  layout "admin"

  def self.default_url_options
    super.except(:locale)
  end

  def sign_in
  end
end
