namespace :consent do
  desc "Backfill consented_to_service onto client objects"
  task backfill: :environment do
    Intake.where.not(primary_consented_to_service_at: nil).joins(:client).find_each do |intake|
      intake.client.update(consented_to_service_at: intake.primary_consented_to_service_at)
    end
    Archived::Intake2021.where.not(primary_consented_to_service_at: nil).joins(:client).find_each do |intake|
      intake.client.update(consented_to_service_at: intake.primary_consented_to_service_at)
    end
  end
end