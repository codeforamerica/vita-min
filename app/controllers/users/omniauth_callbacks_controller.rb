class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def idme
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # returning user
      sign_in @user, event: :authentication
      redirect_to overview_questions_path
    else
      # new user
      @user.intake = Intake.create
      @user.save
      sign_in @user, event: :authentication
      redirect_to overview_questions_path
    end
  end
end