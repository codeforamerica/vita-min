class Ctc::Portal::PortalController < Ctc::Portal::BaseAuthenticatedController
  include RecaptchaScoreConcern
  before_action :load_current_submission
  before_action :ensure_current_submission, except: [:home]
  before_action :redirect_if_identity_verification_needed, only: [:home]
  skip_before_action :redirect_if_read_only, only: [:home]

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
    @submit_enabled = intake_updated_since_last_submission && !direct_deposit_missing_bank_account && !current_client.intake.benefits_eligibility.disqualified_for_simplified_filing?
    @benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: current_client.intake.default_tax_return, dependents: current_client.intake.dependents)
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
