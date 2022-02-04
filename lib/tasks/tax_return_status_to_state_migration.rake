namespace :tax_return_state do
  desc 'BulkTaxReturnUpdate status -> state'
  task bulk_update_migrate: [:environment] do
    BulkTaxReturnUpdate.find_each do |btru|
      btru.update(state: btru.status)
    end
  end
  
  task tax_return_2021_migrate: [:environment] do
    TaxReturn.where(state: nil, year: 2021).find_in_batches do |batch|
      updates = batch.map { |tax_return| { id: tax_return.id, state: tax_return.status } }
      TaxReturn.upsert_all(updates)
    end
  end

  task tax_return_migrate: [:environment] do
    TaxReturn.where(state: nil).where.not(status: "intake_before_consent").find_in_batches do |batch|
      updates = batch.map { |tax_return| { id: tax_return.id, state: tax_return.status } }
      TaxReturn.upsert_all(updates)
    end
  end

  task tax_return_low_priority_migrate: [:environment] do
    TaxReturn.where(state: nil).where(status: "intake_before_consent").find_in_batches do |batch|
      updates = batch.map { |tax_return| { id: tax_return.id, state: tax_return.status } }
      TaxReturn.upsert_all(updates)
    end
  end
end