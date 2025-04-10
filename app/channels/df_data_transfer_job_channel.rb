class DfDataTransferJobChannel < ApplicationCable::Channel
  def subscribed
    intake = current_state_file_intake
    stream_for intake
    if intake.raw_direct_file_data
      DfDataTransferJobChannel.broadcast_job_complete(intake)
    end
  end

  def self.broadcast_job_complete(intake)
    binding.pry
    broadcast_to(intake, ["The job is complete"])
  end
end
