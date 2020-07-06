class ZendeskController < ApplicationController
  layout "admin"

  def self.default_url_options
    super.except(:locale)
  end

  def sign_in
  end
end
