module RecaptchaScoreConcern
  def recaptcha_score_param(action)
    if verify_recaptcha(action: action)
      if recaptcha_reply.present?
        DatadogApi.increment("recaptcha.success")

        return {
          recaptcha_score: recaptcha_reply['score'],
          recaptcha_action: action
        }
      end
    elsif recaptcha_reply.present?
      error_codes = Array(recaptcha_reply["error-codes"]).join("_")
      DatadogApi.increment("recaptcha.failure.with_error", tags: ["error_codes:#{error_codes}"])
    else
      DatadogApi.increment("recaptcha.failure.unknown")
    end
    {}
  end
end
