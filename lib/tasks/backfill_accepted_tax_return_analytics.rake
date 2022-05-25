namespace :backfill_accepted_tax_return_analytics do
  desc "Backfill data to AcceptedTaxReturnAnalytics for 2021 TaxReturns"
  task backfill_2021: :environment do
    errored_updates = []
    successes = 0

    AcceptedTaxReturnAnalytics.where("created_at >= ?", Date.new(2022, 1, 1)).find_in_batches(batch_size: 100) do |batch|
      batch.each do |record|
        begin
          record.update!(record.calculated_benefits_attrs)
          successes += 1
        rescue => e
          puts "---Error backfilling AcceptedTaxReturnAnalytics ##{record.id} because of: #{e.message}"
          errored_updates << record.id
        end
      end
    end

    puts "===Successfully updated #{successes} AcceptedTaxReturnAnalytics==="
    if errored_updates.present?
      puts "===IDs of AcceptedTaxReturnAnalytics that errored before updating==="
      puts errored_updates
    end
  end
end