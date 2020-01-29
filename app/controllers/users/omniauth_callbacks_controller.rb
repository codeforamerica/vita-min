class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def idme
    @user = User.from_omniauth(request.env["omniauth.auth"])

    unless @user.persisted?
      # new user
      is_new_user = true
      @user.intake = Intake.create
      @user.save
    end

    sign_in @user, event: :authentication
    redirect_to overview_questions_path(is_new_user: is_new_user)
  end
end