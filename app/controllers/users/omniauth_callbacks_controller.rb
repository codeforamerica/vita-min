class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def idme
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      flash[:notice] = "You're signed in!"
      sign_in_and_redirect @user, event: :authentication
    else
      @user.save
      flash[:notice] = "Thank you for verifying your identity!"
      sign_in_and_redirect @user, event: :authentication
    end
  end
end