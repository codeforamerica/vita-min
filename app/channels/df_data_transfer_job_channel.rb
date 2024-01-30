class DfDataTransferJobChannel < ApplicationCable::Channel
  def subscribed
    intake = current_state_file_intake
    if intake.raw_direct_file_data
      DfDataTransferJobChannel.broadcast_job_complete(intake)
    end
    stream_for intake
  end

  def self.broadcast_job_complete(intake)
    broadcast_to(intake, ["The job is complete"])
  end
end
