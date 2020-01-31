class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def idme
    @user = User.from_omniauth(request.env["omniauth.auth"])

    unless @user.persisted?
      # new user
      @user.intake = Intake.create
      @user.save
    end

    sign_in @user, event: :authentication
    redirect_to overview_questions_path
  end

  def failure
    error_type = request.env["omniauth.error.type"]
    error = request.env["omniauth.error"]
    if error_type == :access_denied
      # the user did not grant permission to view their info
      redirect_to identity_needed_path
    elsif error_type == :invalid_credentials && params["logout"] == "success"
      # the user has logged out of ID.me through us
      redirect_to root_path
    else
      raise error
    end
  end
end