class DeleteBarelyStartedGyrIntakesJob < ApplicationJob
  def perform
    Intake::GyrIntake.where("created_at < ?", 2.days.ago).where(primary_consented_to_service_at: nil)
                     .find_in_batches(batch_size: 1000) do |intakes|
      Client.find(intakes.pluck(:client_id)).map(&:destroy)
    end
  end
end