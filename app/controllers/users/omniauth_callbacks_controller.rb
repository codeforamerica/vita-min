class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include IdmeAuthenticatable

  def idme
    has_spouse_param = params["spouse"] == "true"
    @user = User.from_omniauth(request.env["omniauth.auth"])
    is_new_user = !@user.persisted?
    is_consenting_user = @user.consented_to_service_yes?
    is_returning_user = !is_new_user

    is_new_primary_user = !has_spouse_param && is_new_user
    is_new_spouse = has_spouse_param && is_new_user
    is_returning_consenting_user = is_returning_user && is_consenting_user
    is_returning_nonconsenting_user = is_returning_user && !is_consenting_user
    is_primary_but_expected_spouse = (@user == current_user && has_spouse_param)

    if is_primary_but_expected_spouse
      return redirect_to spouse_identity_questions_path(missing_spouse: "true")
    end

    if is_new_spouse
      @user.is_spouse = true
      @user.intake = current_user.intake
      @user.save
      return redirect_to welcome_spouse_questions_path
    end

    if is_returning_consenting_user
      sign_in @user, event: :authentication
      return redirect_to welcome_questions_path
    end

    if is_returning_nonconsenting_user
      sign_in @user, event: :authentication
    elsif is_new_primary_user
      @user.intake = Intake.create(source: source, referrer: referrer)
      @user.save
      sign_in @user, event: :authentication
    end
    redirect_to consent_questions_path
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
    elsif error_type == :invalid_credentials && params["logout"] == "primary"
      # We have signed out the primary user and need to verify the spouse
      redirect_to idme_authorize(spouse: "true")
    else
      raise error
    end
  end
end