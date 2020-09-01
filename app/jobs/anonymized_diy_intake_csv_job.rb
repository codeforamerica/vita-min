class AnonymizedDiyIntakeCsvJob < ZendeskJob
  queue_as :default

  def perform(diy_intake_ids=nil)
    AnonymizedDiyIntakeCsvService.new(diy_intake_ids).store_csv
  end
end
