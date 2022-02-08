namespace :tax_return_state do
  desc 'BulkTaxReturnUpdate status -> state'
  task bulk_update_migrate: [:environment] do
    BulkTaxReturnUpdate.find_each do |btru|
      btru.update(state: btru.status)
      prints "."
    end
  end
  
  task tax_return_2021_migrate: [:environment] do
    TaxReturn.where(state: nil, year: 2021).find_each do |tax_return|
      tax_return.update(state: tax_return.status)
      prints "."
    end
  end

  task tax_return_migrate: [:environment] do
    TaxReturn.where(state: nil).where.not(status: "intake_before_consent").find_each do |tax_return|
      tax_return.update(state: tax_return.status)
      print "."
    end
  end

  task tax_return_low_priority_migrate: [:environment] do
    TaxReturn.where(state: nil).where(status: "intake_before_consent").find_each do |tax_return|
      tax_return.update(state: tax_return.status)
      print "."
    end
  end
end