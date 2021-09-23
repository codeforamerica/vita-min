class Ctc::Portal::PortalController < Ctc::Portal::BaseAuthenticatedController
  include RecaptchaScoreConcern
  before_action :ensure_current_submission, except: [:home]

  def home
    if current_client.efile_submissions.any?
      @submission = current_client.efile_submissions.last
      latest_transition = @submission.last_client_accessible_transition
      @status = latest_transition.present? ? latest_transition.to_state : EfileSubmissionStateMachine.initial_state
      @exposed_error = latest_transition.present? ? latest_transition.exposed_error : nil
      @current_step = nil
      @pdf1040 = current_client.documents.find_by(tax_return: @submission.tax_return, document_type: DocumentTypes::Form1040.key)
    else
      @submission = nil
      @status = "intake_in_progress"
      @exposed_error = nil
      @current_step = current_client.intake.current_step
      @pdf1040 = nil
    end
  end

  def edit_info
    @intake_updated_since_last_submission = SystemNote.where('created_at > ?', @submission.created_at).where(type: [SystemNote::CtcPortalAction, SystemNote::CtcPortalUpdate].map(&:to_s)).any?
  end

  def resubmit
    if @submission.can_transition_to?(:resubmitted)
      unless current_client.efile_security_informations.create(efile_security_params).persisted?
        flash[:alert] = I18n.t("general.enable_javascript")
        return redirect_back(fallback_location: ctc_portal_edit_info_path)
      end
      @submission.transition_to(:resubmitted)
      SystemNote::CtcPortalAction.generate!(
        model: @submission,
        action: 'resubmitted',
        client: current_client
      )
    end
    redirect_to(action: :home)
  end

  def efile_security_params
    params[:ctc_resubmit_form].merge!(recaptcha_score_param('submit'))
    params.require(:ctc_resubmit_form).permit(:device_id,
                                              :user_agent,
                                              :browser_language,
                                              :platform,
                                              :timezone_offset,
                                              :client_system_time,
                                              :recaptcha_score
                                              ).merge(ip_address: request.remote_ip)

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
end
