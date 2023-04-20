class Users::OmniauthController < ApplicationController
  def localized
    # Saves the current locale in the session and redirect to the unscoped path as before b/c devise callbacks cannot deal with dynamic routes
    session[:omniauth_login_locale] = I18n.locale
    redirect_to user_omniauth_authorize_path(params[:provider])
  end
end
