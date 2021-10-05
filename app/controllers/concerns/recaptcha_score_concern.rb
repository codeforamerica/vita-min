module RecaptchaScoreConcern
  def recaptcha_score_param(action)
    if verify_recaptcha(action: action)
      if recaptcha_reply.present?
        return {
          recaptcha_score: recaptcha_reply['score'],
          recaptcha_action: action
        }
      end
    elsif recaptcha_reply.present?
      Sentry.capture_message "Failed to verify recaptcha token due to the following errors: #{recaptcha_reply["error-codes"]}"
    else
      Sentry.capture_message "Something bad happened when attempting recaptcha!"
    end
    {}
  end
end
