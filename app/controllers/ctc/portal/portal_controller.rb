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

  def edit_info
    @current_submission = current_intake.client.efile_submissions.last
  end

  def resubmit
    @submission = current_client.efile_submissions.last
    if @submission.can_transition_to?(:resubmitted)
      efile_attrs = params.require(:ctc_resubmit_form).permit!.merge(ip_address: request.remote_ip)
      current_client.efile_security_informations.create(efile_attrs)
      @submission.transition_to(:resubmitted)
      SystemNote::CtcPortalAction.generate!(
        model: @submission,
        action: 'resubmitted',
        client: current_client
      )
    end
    redirect_to(action: :home)
  end
end
