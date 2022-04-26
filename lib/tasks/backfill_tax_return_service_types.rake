namespace :backfill_tax_return_service_types do
  desc "Backfill missing service_type on tax_returns"
  task backfill: :environment do
    tax_returns_missing_service_type = TaxReturn.where(service_type: nil)
    tax_returns_missing_service_type.find_in_batches(batch_size: 100) do |batch|
      batch.each do |tax_return|
        other_tax_returns_with_service_type = tax_return.client.tax_returns.filter { |tr| tr.service_type.present? }
        if other_tax_returns_with_service_type.present?
          tax_return.update(service_type: other_tax_returns_with_service_type.first.service_type)
        end
      end
      print '.'
    end
  end
end
