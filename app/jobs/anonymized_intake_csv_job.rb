class AnonymizedIntakeCsvJob < ActiveJob::Base
  queue_as :default

  def perform(intake_ids=nil)
    AnonymizedIntakeCsvService.new(intake_ids).store_csv
  end
end
