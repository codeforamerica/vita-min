class ApplicationController < ActionController::Base
  helper_method :include_google_analytics?

  def include_google_analytics?
    false
  end
end
