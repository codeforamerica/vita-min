class DeleteUnconsentedClientsJob < ApplicationJob
  def perform
    Client.where("created_at < ?", 2.days.ago).where(consented_to_service_at: nil).find_in_batches do |clients|
      clients.each(&:destroy)
    end
  end
end