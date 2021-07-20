class Ctc::Portal::PortalController < ApplicationController
  include AuthenticatedClientConcern
  layout "portal"

  def home
    if current_client.efile_submissions.any?
      @status = current_client.efile_submissions.last.current_state
      @current_step = nil
    else
      @status = "intake_in_progress"
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
