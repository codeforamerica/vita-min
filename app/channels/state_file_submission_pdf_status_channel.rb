class StateFileSubmissionPdfStatusChannel < ApplicationCable::Channel
  def subscribed
    @intake = current_state_file_intake
    stream_for @intake
  end

  def status_update
    { status: @intake.submission_pdf.attached? ? :ready : :processing }
  end

  def self.broadcast_status(intake, status)
    broadcast_to(intake, { status: })
  end
end
