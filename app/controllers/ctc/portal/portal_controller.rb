class Ctc::Portal::PortalController < Ctc::Portal::BaseAuthenticatedController
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

  def edit_info; end

  def resubmit
    @submission = current_client.efile_submissions.last
    if @submission.can_transition_to?(:ready_to_resubmit)
      @submission.transition_to(:ready_to_resubmit)
      SystemNote::CtcPortalAction.generate!(
        model: @submission,
        action: 'ready_to_resubmit',
        client: current_client
      )
    end
    redirect_to(action: :home)
  end
end
