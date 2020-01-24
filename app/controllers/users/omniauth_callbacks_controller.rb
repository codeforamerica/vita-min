class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def idme
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      flash[:notice] = "You're signed in!"
      sign_in @user, event: :authentication
      redirect_to overview_questions_path
    else
      @user.save
      flash[:notice] = "Thank you for verifying your identity!"
      sign_in @user, event: :authentication
      redirect_to overview_questions_path
    end
  end
end