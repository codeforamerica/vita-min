namespace :backfill_accepted_tax_return_analytics do
  desc "Backfill data to AcceptedTaxReturnAnalytics for 2020 TaxReturns"
  task backfill_2020: :environment do
    errored_updates = []
    successes = 0

    AcceptedTaxReturnAnalytics.where("created_at <= ?", Date.new(2021, 12, 31)).find_in_batches(batch_size: 100) do |batch|
      batch.each do |record|
        begin
          record.update!(tax_return_year: 2020)
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

  desc "Backfill data to AcceptedTaxReturnAnalytics for 2021 TaxReturns"
  task backfill_2021: :environment do
    errored_updates = []
    successes = 0

    AcceptedTaxReturnAnalytics.where("created_at >= ?", Date.new(2022, 1, 1)).find_in_batches(batch_size: 100) do |batch|
      batch.each do |record|
        tax_return = record.tax_return
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: tax_return.qualifying_dependents)
        total_refund_amount = [benefits.outstanding_ctc_amount, benefits.outstanding_recovery_rebate_credit].compact.sum
        eip3_amount_received = tax_return.intake.eip3_amount_received || 0

        attributes = {
          tax_return_year: 2021,
          advance_ctc_amount_cents: benefits.advance_ctc_amount_received * 100,
          outstanding_ctc_amount_cents: benefits.outstanding_ctc_amount * 100,
          ctc_amount_cents: benefits.ctc_amount * 100,
          eip3_amount_received_cents: eip3_amount_received * 100,
          outstanding_eip3_amount_cents: benefits.outstanding_eip3 * 100,
          total_refund_amount_cents: total_refund_amount * 100,
        }

        begin
          record.update!(attributes)
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