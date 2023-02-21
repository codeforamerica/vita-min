namespace :bought_marketplace_health_insurance do
  desc "Backfill bought_marketplace_health_insurance with bought_health_insurance value"
  task backfill: :environment do
    Intake.where.not(bought_health_insurance: nil)
             .where(bought_marketplace_health_insurance: nil)
             .in_batches(of: 10_000) do |batch|
      batch.update_all('bought_marketplace_health_insurance = bought_health_insurance')
    end
  end
end