class Ctc::Portal::PortalController < Ctc::Portal::BaseAuthenticatedController
  include RecaptchaScoreConcern
  before_action :load_current_submission
  before_action :ensure_current_submission, except: [:home]
  before_action :redirect_if_identity_verification_needed, only: [:home]

  def home
    if @submission.nil?
      @status = "intake_in_progress"
      @exposed_error = nil
      @current_step = current_client.intake.current_step
      @pdf1040 = nil
    else
      latest_transition = @submission.last_client_accessible_transition
      @status = latest_transition.present? ? latest_transition.to_state : EfileSubmissionStateMachine.initial_state
      @exposed_error = latest_transition.present? ? latest_transition.exposed_error : nil
      @current_step = nil
      @pdf1040 = current_client.documents.find_by(tax_return: @submission.tax_return, document_type: DocumentTypes::Form1040.key)
    end
  end

  def edit_info
    intake_updated_since_last_submission = SystemNote
      .where(client: current_client)
      .where('created_at > ?', @submission.created_at)
      .where(type: [SystemNote::CtcPortalAction, SystemNote::CtcPortalUpdate].map(&:to_s))
      .any?
    direct_deposit_missing_bank_account = current_client.intake.refund_payment_method_direct_deposit? && !current_client.intake.bank_account.present?
    @submit_enabled = intake_updated_since_last_submission && !direct_deposit_missing_bank_account
    @benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: current_client.intake.default_tax_return, dependents: current_client.intake.dependents)
  end

  def resubmit
    if @submission.can_transition_to?(:resubmitted)
      unless current_client.efile_security_informations.create(efile_security_params).persisted?
        flash[:alert] = I18n.t("general.enable_javascript")
        return redirect_back(fallback_location: ctc_portal_edit_info_path)
      end
      return redirect_back(fallback_location: ctc_portal_edit_info_path) unless @submission.tax_return.under_submission_limit?
      @submission.transition_to(:resubmitted)
      if recaptcha_score_param('resubmit').present?
        current_client.recaptcha_scores.create(
          score: recaptcha_score_param('resubmit')[:recaptcha_score],
          action: recaptcha_score_param('resubmit')[:recaptcha_action]
        )
      end
      SystemNote::CtcPortalAction.generate!(
        model: @submission,
        action: 'resubmitted',
        client: current_client
      )
    end
    redirect_to(action: :home)
  end

  def efile_security_params
    params.require(:ctc_resubmit_form).permit(:device_id,
                                              :user_agent,
                                              :browser_language,
                                              :platform,
                                              :timezone_offset,
                                              :timezone,
                                              :client_system_time,
                                              :recaptcha_score)
          .merge(ip_address: request.remote_ip)
          .merge(recaptcha_score: recaptcha_score_param('resubmit')[:recaptcha_score])

  end

  def ensure_current_submission
    @submission = current_client.efile_submissions.last
    unless @submission.present?
      Sentry.capture_message "Client #{current_client.id} unexpectedly lacks an efile submission."
      redirect_to(action: :home) and return
    end
    if @submission.current_state == "fraud_hold"
      redirect_to(action: :home) and return
    end
  end

  def load_current_submission
    @submission = current_client.efile_submissions.order(created_at: :asc).last
  end

  def redirect_if_identity_verification_needed
    return unless @submission && @submission.current_state == "fraud_hold"

    if !current_client.identity_decision_made? && current_client.verification_attempts.reviewing.empty?
      redirect_to ctc_portal_verification_attempt_path and return
    end
  end
end
