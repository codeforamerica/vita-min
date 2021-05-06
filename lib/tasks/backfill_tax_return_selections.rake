namespace :backfill_tax_return_selections do
  desc "seeds tax_return_selections with client_selections"
  task "backfill" => :environment do
    BackfillTaxReturnSelections.perform_later()
  end
end
