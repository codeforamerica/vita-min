class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include IdmeAuthenticatable

  def idme
    has_spouse_param = params["spouse"] == "true"
    has_after_login_param = params["after_login"].present?
    @user = User.from_omniauth(request.env["omniauth.auth"])
    is_new_user = !@user.persisted?
    is_consenting_user = @user.consented_to_service_yes?
    is_returning_user = !is_new_user
    is_returning_spouse = @user.is_spouse && is_returning_user

    is_new_primary_user = !has_spouse_param && is_new_user
    is_new_spouse = has_spouse_param && is_new_user
    is_returning_consenting_primary_user = is_returning_user && is_consenting_user && !is_returning_spouse
    is_returning_nonconsenting_primary_user = is_returning_user && !is_consenting_user && !is_returning_spouse
    is_returning_consenting_spouse = is_returning_spouse && is_consenting_user
    is_returning_nonconsenting_spouse = is_returning_spouse && !is_consenting_user
    is_primary_but_expected_spouse = (@user == current_user && has_spouse_param)
    used_spouse_auth_only_link = session[:authenticate_spouse_only]

    if is_primary_but_expected_spouse
      return redirect_to spouse_identity_questions_path(missing_spouse: "true")
    end

    if is_returning_user && is_consenting_user && has_after_login_param
      sign_in @user, event: :authentication
      return redirect_to params["after_login"]
    end

    # A new intake is created before sign in so that we can save answers to questions that are asked before sign in.
    # This intake is stored in session[:intake_id]
    # If a returning user signs in, we want to delete this new intake because the user will already have an intake.
    # In the case of a spouse who came to the sign in page with a verify-spouse link, the intake
    # in the session will be the one corresponding to the token in the link, so we ensure this doesn't get deleted.
    # We also ensure that we don't destroy intakes with associated users.
    should_delete_duplicate_intake = session[:intake_id] && is_returning_user && !used_spouse_auth_only_link
    if should_delete_duplicate_intake
      intake_from_session = Intake.find(session[:intake_id])
      intake_from_session.destroy! if intake_from_session.users.count == 0
      session[:intake_id] = nil
    end

    if is_new_spouse
      @user.intake = current_intake
      @user.is_spouse = true
      @user.save
      sign_in @user, event: :authentication if used_spouse_auth_only_link
      return redirect_to spouse_consent_questions_path
    end

    if is_returning_consenting_primary_user
      sign_in @user, event: :authentication
      return redirect_to mailing_address_questions_path
    end

    if is_returning_consenting_spouse
      sign_in @user, event: :authentication
      return redirect_to spouse_was_student_questions_path
    end

    if is_returning_nonconsenting_spouse
      sign_in @user, event: :authentication
      return redirect_to spouse_consent_questions_path
    end

    if is_returning_nonconsenting_primary_user
      sign_in @user, event: :authentication
    elsif is_new_primary_user
      intake_from_session = Intake.find_by_id(session[:intake_id]) || Intake.new(source: source, referrer: referrer)
      @user.intake = intake_from_session
      session[:intake_id] = nil
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
      logger.error("#{error}, #{error_type}, intake: #{current_intake&.id}")
      raise error
    end
  end
end
