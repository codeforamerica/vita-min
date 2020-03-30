class BackfillVisitorIdsJob < ApplicationJob
  queue_as :default

  def perform
    intakes_needing_visitor_id = Intake.where(visitor_id: nil)
    intakes_needing_visitor_id.each do |intake|
      generated_visitor_id = SecureRandom.hex(26)
      intake.update(visitor_id: generated_visitor_id)
    end
  end
end
