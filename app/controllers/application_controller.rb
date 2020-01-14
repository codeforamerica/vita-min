class ApplicationController < ActionController::Base
  before_action :set_visitor_id
  helper_method :include_google_analytics?

  def include_google_analytics?
    false
  end

  def set_visitor_id
    return if cookies[:visitor_id].present?
    cookies.permanent[:visitor_id] = SecureRandom.hex(26)
  end

  def visitor_id
    cookies[:visitor_id]
  end
end
