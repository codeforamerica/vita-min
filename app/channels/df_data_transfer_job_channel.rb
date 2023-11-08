class DfDataTransferJobChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_state_file_intake
  end

  def self.broadcast_job_complete(intake)
    broadcast_to(intake, ["The job is complete"])
  end
end
