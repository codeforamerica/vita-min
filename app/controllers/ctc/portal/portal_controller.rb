class Ctc::Portal::PortalController < ApplicationController
  include AuthenticatedClientConcern
  layout "portal"

  def home
    if current_client.efile_submissions.any?
      submission = current_client.efile_submissions.last
      @status = submission.current_state
      @errors = submission.last_transition&.stored_errors
      @current_step = nil
    else
      @status = "intake_in_progress"
      @errors = nil
      @current_step = current_client.intake.current_step
    end
  end

  private

  def service_type
    :ctc
  end

  def wrapping_layout
    service_type
  end
end
